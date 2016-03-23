From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 2/9] udp: Add noreference lookup functions
Date: Wed, 23 Mar 2016 16:17:59 -0700
Message-ID: <CALx6S35pPLoyY6hiOg1WKKe4FUATgJQncWvoxJe-Z2NoOMe2eA@mail.gmail.com>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
	<1458772618-845742-3-git-send-email-tom@herbertland.com>
	<1458773986.10868.54.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36666 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755245AbcCWXSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 19:18:00 -0400
Received: by mail-io0-f180.google.com with SMTP id 124so68589930iov.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 16:17:59 -0700 (PDT)
In-Reply-To: <1458773986.10868.54.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 3:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-03-23 at 15:36 -0700, Tom Herbert wrote:
>> This patches adds udp6_lib_lookup_skb_noref, udp4_lib_lookup_skb_noref
>> and related support to allow a caller to lookup a UDP socket
>> without automatically taking a reference. The lookup and caller
>> use of the socket must be done under rcu_read_lock.
>>
>> This feature will be used in a fast receive encapsulation path and
>> also when performing GRO through callout in the UDP socket.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>> ---
>
> As already mentioned in the past, you can not do a UDP lookup without
> taking a reference, because we use SLAB_DESTROY_BY_RCU rules which are
> strict.
>
> Only taking a reference and re-doing the keys check can make sure the
> lookup result makes sense (as we check multiple words and there is no
> way it can be done atomically)
>
> This is explained in include/linux/slab.h and
> Documentation/RCU/rculist_nulls.txt
>
> If you want that to happen, we need first to not use
> SLAB_DESTROY_BY_RCU.
>
> Then, we do not need to take a reference at all, even for the regular
> UDP stack unicast receive path.
>
Thanks Eric. Do you think it is reasonable to not use
SLAB_DESTROY_BY_RCU for UDP since it probably has a much lower
allocation rate than what we'd see in TCP?

Tom

>
>
