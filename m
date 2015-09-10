From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next] Revert "net/ipv6: add sysctl option
 accept_ra_min_hop_limit"
Date: Thu, 10 Sep 2015 11:19:04 +0200
Message-ID: <20150910091904.GA22575@bistromath.redhat.com>
References: <20150902094301.GA6434@via.ecp.fr>
 <20150902.161110.223512323094619164.davem@davemloft.net>
 <20150909101054.GA6753@bistromath.redhat.com>
 <CAPwn2JRcHBSj4mnYZyjmYinpcb9yB6Makcw+ynSyMaQJg0cYaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	network dev <netdev@vger.kernel.org>,
	=?utf-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295AbbIJJTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 05:19:08 -0400
Content-Disposition: inline
In-Reply-To: <CAPwn2JRcHBSj4mnYZyjmYinpcb9yB6Makcw+ynSyMaQJg0cYaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

2015-09-10, 10:54:38 +0800, Hangbin Liu wrote:
> > Can we still modify the behavior of this sysctl? It's already been in
> > Linus's tree for a while, but if we can, I would rather restrict the
> > values we let the user write to accept_ra_min_hop_limit, as anything
> > outside [0..255] does not really make sense.
> 
> Yes, so the checked if (in6_dev->cnf.accept_ra_min_hop_limit < 256 &&
> ra_msg->icmph.icmp6_hop_limit)  make sure we only update the value between
> [1..255].

I was thinking of returning -EINVAL when the user tries to set it to
300, using proc_dointvec_minmax.


> > Allowing an RA to update the hop limit if
> >
> >    current hop limit < RA.hop_limit < accept_ra_min_hop_limit
> >
> > might also be desirable, but I'm not so sure about this case.
> 
> Yes, and we also should allow an RA to update the hop limit if
> 
> accept_ra_min_hop_limit <= RA.hop_limit < current hop limit
> 
> e.g accept_ra_min_hop_limit = RA.hop_limit =64, current hop limit = 128

Yes, that's what we're doing at the moment, and I would leave it as is.


Thanks,

-- 
Sabrina
