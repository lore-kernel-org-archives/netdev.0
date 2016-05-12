From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH] udp: Resolve NULL pointer dereference
Date: Thu, 12 May 2016 09:51:24 -0700
Message-ID: <CAKgT0Udv5wWDUz7Mv8eEQ2DUEQxYzMarw4+VZe0Kqh3XPu1b4w@mail.gmail.com>
References: <20160512022306.3691.40769.stgit@localhost.localdomain>
	<1463024588.23934.158.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36416 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbcELQvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 12:51:25 -0400
Received: by mail-io0-f173.google.com with SMTP id i75so97203723ioa.3
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 09:51:24 -0700 (PDT)
In-Reply-To: <1463024588.23934.158.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 11, 2016 at 8:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-05-11 at 19:24 -0700, Alexander Duyck wrote:
>> While testing an OpenStack configuration using VXLANs I saw the following
>> call trace:
>
>>
>> I believe the trace is pointing to the call to dev_net(dev) in
>> udp4_lib_lookup_skb.  If I am not mistaken I believe it is possible for us
>> to have skb_dst(skb)->dev be NULL.  So to resolve that I am adding a check
>> for this case and skipping the assignment if such an event occurs.
>
> skb_dst(skb)->dev can be NULL ???

That is what appears to be happening.  Though I can do some more
research into this.

> Why only UDP ipv4 would need a fix, and not ipv6 ?

Yeah, I should probably fix IPv6 as well if there is an issue.

> Looks the bug is somewhere else maybe ?

I was thinking about it last night and I am not certain we should even
see skb_dst(skb) set as Cong mentioned.  I'm wondering if I should
update the code to just use skb->dev because these functions are
currently only used in the GRO path anyway so it isn't as if skb_dst
should be populated.

- Alex
