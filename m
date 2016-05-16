From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v5 net-next 03/14] ipv6: Fix nexthdr for reinjection
Date: Mon, 16 May 2016 11:35:04 -0700
Message-ID: <CALx6S34RXj_y6sAiv+q6RPVtXo6HUZ04mNCjR73sjyyJM9UjnA@mail.gmail.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
	<1463355755-3481375-4-git-send-email-tom@herbertland.com>
	<20160516211925.1498653f@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34250 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343AbcEPSfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:35:05 -0400
Received: by mail-io0-f172.google.com with SMTP id 190so220895808iow.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 11:35:04 -0700 (PDT)
In-Reply-To: <20160516211925.1498653f@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 11:19 AM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> Hi,
>
> On Sun, 15 May 2016 16:42:24 -0700 Tom Herbert <tom@herbertland.com> wrote:
>> In ip6_input_finish the nexthdr protocol is retrieved from the
>> next header offset that is returned in the cb of the skb.
>> This method does not work for UDP encapsulation that may not
>> even have a concept of a nexthdr field (e.g. FOU).
>>
>> This patch checks for a final protocol (INET6_PROTO_FINAL) when a
>> protocol handler returns > 1. If the protocol is not final then
>
> If you respin due to other reasons:  s/> 1/> 0/
>
Will do. Thanks!

Tom

>> resubmission is performed on nhoff value. If the protocol is final
>> then the nexthdr is taken to be the return value.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>
> Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
