From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Thu, 25 Jan 2007 15:18:59 -0500
Message-ID: <45B910B3.5000809@hp.com>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org> <20070122181528.GD21059@hmsreliant.homelinux.net> <20070123.091820.104515696.yoshfuji@linux-ipv6.org> <20070123205118.GC582@hmsreliant.homelinux.net> <1169690087.23312.7.camel@w-sridhar2.beaverton.ibm.com> <20070125133340.GA8891@hmsreliant.homelinux.net> <45B8E60B.7080809@hp.com> <20070125194500.GB8891@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kg?=
	 =?UTF-8?B?LyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:51225 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030525AbXAYUTF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 15:19:05 -0500
In-Reply-To: <20070125194500.GB8891@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil

> @@ -1027,15 +1029,17 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
>  				}
>  			}
>  
> -			/* Rule 3: Avoid deprecated address */
> +			/* Rule 3: Avoid deprecated and optimistic address */
>  			if (hiscore.rule < 3) {
>  				if (ipv6_saddr_preferred(hiscore.addr_type) ||
> -				    !(ifa_result->flags & IFA_F_DEPRECATED))
> +				    ((!(ifa_result->flags & IFA_F_DEPRECATED)) && 
> +				    (!(ifa_result->flags & IFA_F_OPTIMISTIC))))

One style comment.  Looks like some extra parenthesis that I don't thing are needed.
I think you can say

+				    (!(ifa_result->flags & IFA_F_DEPRECATED)) && 
+				     !(ifa_result->flags & IFA_F_OPTIMISTIC))))


>  					hiscore.attrs |= IPV6_SADDR_SCORE_PREFERRED;
>  				hiscore.rule++;
>  			}
>  			if (ipv6_saddr_preferred(score.addr_type) ||
> -			    !(ifa->flags & IFA_F_DEPRECATED)) {
> +			    ((!(ifa->flags & IFA_F_DEPRECATED)) &&
> +			    (!(ifa_result->flags & IFA_F_OPTIMISTIC)))) {

same here.

>  				score.attrs |= IPV6_SADDR_SCORE_PREFERRED;
>  				if (!(hiscore.attrs & IPV6_SADDR_SCORE_PREFERRED)) {
>  					score.rule = 3;

-vlad

