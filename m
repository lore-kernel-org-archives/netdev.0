From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net-next v2] ipv6,mcast: always hold idev->lock before mca_lock
Date: Sat, 29 Jun 2013 15:53:21 +0200
Message-ID: <20130629135321.GA5884@order.stressinduktion.org>
References: <1372512649-7550-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, dingtianhong <dingtianhong@huawei.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:45291 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280Ab3F2NxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 09:53:22 -0400
Content-Disposition: inline
In-Reply-To: <1372512649-7550-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 29, 2013 at 09:30:49PM +0800, Cong Wang wrote:
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -86,6 +86,9 @@ extern int			ipv6_dev_get_saddr(struct net *net,
>  					       const struct in6_addr *daddr,
>  					       unsigned int srcprefs,
>  					       struct in6_addr *saddr);
> +extern int			__ipv6_get_lladdr(struct inet6_dev *idev,
> +						  struct in6_addr *addr,
> +						  unsigned char banned_flags);
>  extern int			ipv6_get_lladdr(struct net_device *dev,
>  						struct in6_addr *addr,
>  						unsigned char banned_flags);
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 4e4cc1f..611b5cc 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1444,8 +1444,8 @@ try_nextdev:
>  }
>  EXPORT_SYMBOL(ipv6_dev_get_saddr);
>  
> -static int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
> -			     unsigned char banned_flags)
> +int __ipv6_get_lladdr(struct inet6_dev *idev, struct in6_addr *addr,
> +		      unsigned char banned_flags)
>  {
>  	struct inet6_ifaddr *ifp;
>  	int err = -EADDRNOTAVAIL;
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 72c8bfe..dd0de91 100644

If we export __ipv6_get_lladdr in a header, shouldn't we also EXPORT_SYMBOL
it? I am not sure but would have done so.

Thanks,

  Hannes
