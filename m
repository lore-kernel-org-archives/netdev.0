From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] ipv6 addrconf: Ignore requests to set NODAD flag when changing addresses
Date: Thu, 5 Jun 2008 11:04:47 +0200
Message-ID: <20080605090447.GL20815@postel.suug.ch>
References: <20080604234751.GH20815@postel.suug.ch> <20080605.115314.80065467.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, usagi-core@ml.linux-ipv6.org,
	nakam@gomagoma.org, takamiya@po.ntts.co.jp
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44323 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721AbYFEJE1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 05:04:27 -0400
Content-Disposition: inline
In-Reply-To: <20080605.115314.80065467.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2008-06-05 11:53
> And well, it does not take effect so far, but 
> DAD after link failure logic is planned in long term.
> So current code is okay to me.

Alright, that makes sense if that code ever is written.

I'm not sure I understand your new patch though, why do you want to
disable setting the nodad flag for new addresses nowW?

> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3a83557..05dcfd8 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3191,7 +3191,7 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u8 ifa_flags,
>  		prefered_lft = 0x7FFFFFFF/HZ;
>  
>  	spin_lock_bh(&ifp->lock);
> -	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_NODAD | IFA_F_HOMEADDRESS)) | ifa_flags;
> +	ifp->flags = (ifp->flags & ~(IFA_F_DEPRECATED | IFA_F_PERMANENT | IFA_F_HOMEADDRESS)) | ifa_flags;
>  	ifp->tstamp = jiffies;
>  	ifp->valid_lft = valid_lft;
>  	ifp->prefered_lft = prefered_lft;
> @@ -3245,7 +3245,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
>  		return -ENODEV;
>  
>  	/* We ignore other flags so far. */
> -	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
> +	ifa_flags = ifm->ifa_flags & IFA_F_HOMEADDRESS;
>  
>  	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
>  	if (ifa == NULL) {
> 
> --yoshfuji
> 
