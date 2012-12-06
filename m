From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 6/8] bna: Add Stats Clear Counter
Date: Thu, 6 Dec 2012 02:19:42 +0000
Message-ID: <1354760382.17107.140.camel@deadeye.wl.decadent.org.uk>
References: <1354748470-26293-1-git-send-email-rmody@brocade.com>
	 <1354748470-26293-7-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49131 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026Ab2LFCTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 21:19:48 -0500
In-Reply-To: <1354748470-26293-7-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-05 at 15:01 -0800, Rasesh Mody wrote:
> Added Stats clear counter to the bfi_enet_stats_mac structure and ethtool stats
>  
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Since this structure appears to be part of the firmware interface, you
should combine this (and any other interface changes) with the change to
the requested firmware version (7/8).

Ben.

> ---
>  drivers/net/ethernet/brocade/bna/bfi_enet.h     |    1 +
>  drivers/net/ethernet/brocade/bna/bnad_ethtool.c |    1 +
>  2 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/brocade/bna/bfi_enet.h b/drivers/net/ethernet/brocade/bna/bfi_enet.h
> index eef6e1f..7d10e33 100644
> --- a/drivers/net/ethernet/brocade/bna/bfi_enet.h
> +++ b/drivers/net/ethernet/brocade/bna/bfi_enet.h
> @@ -787,6 +787,7 @@ struct bfi_enet_stats_bpc {
>  
>  /* MAC Rx Statistics */
>  struct bfi_enet_stats_mac {
> +	u64 stats_clr_cnt;	/* times this stats cleared */
>  	u64 frame_64;		/* both rx and tx counter */
>  	u64 frame_65_127;		/* both rx and tx counter */
>  	u64 frame_128_255;		/* both rx and tx counter */
> diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> index 40e1e84..455b5a2 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> @@ -102,6 +102,7 @@ static const char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
>  	"rx_unmap_q_alloc_failed",
>  	"rxbuf_alloc_failed",
>  
> +	"mac_stats_clr_cnt",
>  	"mac_frame_64",
>  	"mac_frame_65_127",
>  	"mac_frame_128_255",

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
