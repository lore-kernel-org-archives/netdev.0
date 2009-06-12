From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH -next] cnic: fix build for INET=n or IPV6=m
Date: Fri, 12 Jun 2009 11:04:54 -0700
Message-ID: <1244829894.9225.63.camel@HP1>
References: <4A3293E9.7020204@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Randy Dunlap" <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2960 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753531AbZFLSLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2009 14:11:46 -0400
In-Reply-To: <4A3293E9.7020204@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2009-06-12 at 10:44 -0700, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix cnic build for case of CONFIG_INET=n.
> Fix cnic build for case of CONFIG_IPV6=m and CONFIG_CNIC=y.
> 
> Fixes these build errors (from different builds):
> 
> cnic.c:(.text+0x236a1d): undefined reference to `ip_route_output_key'
> cnic.c:(.text+0x15a8e8): undefined reference to `ip6_route_output'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Acked-by: Michael Chan <mchan@broadcom.com>

Thanks.
> ---
>  drivers/net/cnic.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> --- linux-next-20090612.orig/drivers/net/cnic.c
> +++ linux-next-20090612/drivers/net/cnic.c
> @@ -1454,6 +1454,7 @@ static inline u16 cnic_get_vlan(struct n
>  static int cnic_get_v4_route(struct sockaddr_in *dst_addr,
>  			     struct dst_entry **dst)
>  {
> +#if defined(CONFIG_INET)
>  	struct flowi fl;
>  	int err;
>  	struct rtable *rt;
> @@ -1465,12 +1466,15 @@ static int cnic_get_v4_route(struct sock
>  	if (!err)
>  		*dst = &rt->u.dst;
>  	return err;
> +#else
> +	return -ENETUNREACH;
> +#endif
>  }
>  
>  static int cnic_get_v6_route(struct sockaddr_in6 *dst_addr,
>  			     struct dst_entry **dst)
>  {
> -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
>  	struct flowi fl;
>  
>  	memset(&fl, 0, sizeof(fl));
> @@ -1550,7 +1554,7 @@ static int cnic_get_route(struct cnic_so
>  	clear_bit(SK_F_IPV6, &csk->flags);
>  
>  	if (is_v6) {
> -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +#if defined(CONFIG_IPV6) || (defined(CONFIG_IPV6_MODULE) && defined(MODULE))
>  		set_bit(SK_F_IPV6, &csk->flags);
>  		err = cnic_get_v6_route(&saddr->remote.v6, &dst);
>  		if (err)
> 


