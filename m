From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Fri, 02 Feb 2007 16:28:01 -0500
Message-ID: <45C3ACE1.8010800@hp.com>
References: <20070129213013.GA26841@hmsreliant.homelinux.net> <20070130.072536.129403235.yoshfuji@linux-ipv6.org> <20070130130208.GA3723@hmsreliant.homelinux.net> <20070131.011629.84005028.yoshfuji@linux-ipv6.org> <20070131205443.GA12237@hmsreliant.homelinux.net> <20070202190634.GA29001@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>, vladislav.yasevich@hp.com,
	sri@us.ibm.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, kaber@coreworks.de,
	netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:34040 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946095AbXBBV2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 16:28:13 -0500
In-Reply-To: <20070202190634.GA29001@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil,

> @@ -830,7 +836,8 @@ retry:
>  	ift = !max_addresses ||
>  	      ipv6_count_addresses(idev) < max_addresses ? 
>  		ipv6_add_addr(idev, &addr, tmp_plen,
> -			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORARY) : NULL;
> +			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, 
> +			      IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;

So why are you always adding these as optimistic now?  Shouldn't this be 
triggering off idev->cnf.optimistic_dad?  I know you're clearing it in 
ipv6_add_addr(), but I liked Vlad's suggestion of not setting it 
initially since this way seems backwards.

> @@ -2123,7 +2142,8 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr
>  {
>  	struct inet6_ifaddr * ifp;
>  
> -	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
> +	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, 
> +		            IFA_F_PERMANENT|IFA_F_OPTIMISTIC);

Here too.

-Brian
