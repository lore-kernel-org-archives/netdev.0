From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH net] rtnetlink: fix rtnl message size computation for XDP
Date: Tue, 15 Nov 2016 11:05:40 -0800
Message-ID: <20161115190540.GA10191@gmail.com>
References: <0169d2419991a4ba533087a4fda70420ccdaca30.1479204870.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:33366 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752754AbcKOTFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 14:05:43 -0500
Received: by mail-pg0-f41.google.com with SMTP id 3so69716091pgd.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 11:05:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <0169d2419991a4ba533087a4fda70420ccdaca30.1479204870.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 11:16:35AM +0100, Sabrina Dubroca wrote:
> rtnl_xdp_size() only considers the size of the actual payload attribute,
> and misses the space taken by the attribute used for nesting (IFLA_XDP).
> 
> Fixes: d1fdd9138682 ("rtnl: add option for setting link xdp prog")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Reviewed-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>  net/core/rtnetlink.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 5aeb61aadd32..5b4c3ba507d0 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -901,7 +901,8 @@ static size_t rtnl_port_size(const struct net_device *dev,
>  
>  static size_t rtnl_xdp_size(const struct net_device *dev)
>  {
> -	size_t xdp_size = nla_total_size(1);	/* XDP_ATTACHED */
> +	size_t xdp_size = nla_total_size(0) +	/* nest IFLA_XDP */
> +			  nla_total_size(1);	/* XDP_ATTACHED */
>  
>  	if (!dev->netdev_ops->ndo_xdp)
>  		return 0;
> -- 
> 2.10.2
> 
