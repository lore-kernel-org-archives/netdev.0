From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net-next] Revert "net/ipv6: add sysctl option accept_ra_min_hop_limit"
Date: Fri, 11 Sep 2015 09:29:12 +0800
Message-ID: <CAPwn2JQy9J85fxT9pEh1Wfm0Qafs7rJGm+Y96BVNwne+1phCHQ@mail.gmail.com>
References: <20150902094301.GA6434@via.ecp.fr>
	<20150902.161110.223512323094619164.davem@davemloft.net>
	<20150909101054.GA6753@bistromath.redhat.com>
	<CAPwn2JRcHBSj4mnYZyjmYinpcb9yB6Makcw+ynSyMaQJg0cYaQ@mail.gmail.com>
	<20150910091904.GA22575@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	network dev <netdev@vger.kernel.org>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38587 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbbIKB3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 21:29:12 -0400
Received: by igxx6 with SMTP id x6so29015995igx.1
        for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 18:29:12 -0700 (PDT)
In-Reply-To: <20150910091904.GA22575@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sabrina,

2015-09-10 17:19 GMT+08:00 Sabrina Dubroca <sd@queasysnail.net>:
> Hello,
>
> 2015-09-10, 10:54:38 +0800, Hangbin Liu wrote:
>> > Can we still modify the behavior of this sysctl? It's already been in
>> > Linus's tree for a while, but if we can, I would rather restrict the
>> > values we let the user write to accept_ra_min_hop_limit, as anything
>> > outside [0..255] does not really make sense.
>>
>> Yes, so the checked if (in6_dev->cnf.accept_ra_min_hop_limit < 256 &&
>> ra_msg->icmph.icmp6_hop_limit)  make sure we only update the value between
>> [1..255].
>
> I was thinking of returning -EINVAL when the user tries to set it to
> 300, using proc_dointvec_minmax.

I'm OK with this. But we can also set cnf.hop_limit to 300,  if add check for
accept_ra_min_hop_limit, we'd better check all hop_limit values.

Thanks
Hangbin
