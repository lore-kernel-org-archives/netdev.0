From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: [PATCH] ipv6: Add IFA_F_DADFAILED flag
Date: Tue, 08 Sep 2009 15:57:27 +0200
Message-ID: <1252418247.5827.8.camel@fnki-nb00130>
References: <4AA1C0FF.4030109@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: david Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:54038 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754546AbZIHN5g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2009 09:57:36 -0400
In-Reply-To: <4AA1C0FF.4030109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-09-04 at 21:38 -0400, Brian Haley wrote:
> [Note: if this is accepted I'll send out a patch for iproute,
>  if you'd prefer to not use the last ifa_flag I'll send a
>  much larger patch that does this differently :) ]
> 
> 
> Add IFA_F_DADFAILED flag to denote an IPv6 address that has
> failed Duplicate Address Detection, that way tools like
> /sbin/ip can be more informative.
> 
> 3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>     inet6 2001:db8::1/64 scope global tentative dadfailed 
>        valid_lft forever preferred_lft forever
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> ---
> 
> diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
> index a60c821..fd97404 100644
> --- a/include/linux/if_addr.h
> +++ b/include/linux/if_addr.h
> @@ -41,6 +41,7 @@ enum
>  
>  #define	IFA_F_NODAD		0x02
>  #define IFA_F_OPTIMISTIC	0x04
> +#define IFA_F_DADFAILED		0x08
>  #define	IFA_F_HOMEADDRESS	0x10
>  #define IFA_F_DEPRECATED	0x20
>  #define IFA_F_TENTATIVE		0x40
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 43b3c9f..6532966 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1376,7 +1376,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
>  	if (ifp->flags&IFA_F_PERMANENT) {
>  		spin_lock_bh(&ifp->lock);
>  		addrconf_del_timer(ifp);
> -		ifp->flags |= IFA_F_TENTATIVE;
> +		ifp->flags |= IFA_F_DADFAILED;

I think you still have to set IFA_F_TENTATIVE here, too, otherwise
ipv6_dev_get_saddr() will use this address. 		

