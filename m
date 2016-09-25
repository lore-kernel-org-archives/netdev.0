From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH][V2] mlxsw: spectrum: remove redundant check if err is
 zero
Date: Sun, 25 Sep 2016 08:08:55 +0300
Message-ID: <20160925050855.GA4050@splinter>
References: <20160925010338.2734-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hariprasad S <hariprasad@chelsio.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:39012 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751039AbcIYFI7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 01:08:59 -0400
Content-Disposition: inline
In-Reply-To: <20160925010338.2734-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 24, 2016 at 06:03:38PM -0700, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> There is an earlier check and return if err is non-zero, so
> the check to see if it is zero is redundant in every iteration
> of the loop and hence the check can be removed.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

The subject and commit message are wrong. I think you copy-pasted them
from an earlier patch.

> ---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
> index 2a61617..1073673 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
> @@ -117,11 +117,11 @@ static int validate_filter(struct net_device *dev,
>  	return 0;
>  }
>  
> -static unsigned int get_filter_steerq(struct net_device *dev,
> -				      struct ch_filter_specification *fs)
> +static int get_filter_steerq(struct net_device *dev,
> +			     struct ch_filter_specification *fs)
>  {
>  	struct adapter *adapter = netdev2adap(dev);
> -	unsigned int iq;
> +	int iq;
>  
>  	/* If the user has requested steering matching Ingress Packets
>  	 * to a specific Queue Set, we need to make sure it's in range
> @@ -443,10 +443,10 @@ int __cxgb4_set_filter(struct net_device *dev, int filter_id,
>  		       struct filter_ctx *ctx)
>  {
>  	struct adapter *adapter = netdev2adap(dev);
> -	unsigned int max_fidx, fidx, iq;
> +	unsigned int max_fidx, fidx;
>  	struct filter_entry *f;
>  	u32 iconf;
> -	int ret;
> +	int iq, ret;
>  
>  	max_fidx = adapter->tids.nftids;
>  	if (filter_id != (max_fidx + adapter->tids.nsftids - 1) &&
> -- 
> 2.9.3
> 
