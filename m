From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: [PATCH v4 09/10] bnx2x: Support for byte queue limits
Date: Tue, 29 Nov 2011 11:43:35 +0200
Message-ID: <1322559815.25184.3.camel@lb-tlvb-dmitry>
References: <alpine.DEB.2.00.1111281821300.23758@pokey.mtv.corp.google.com>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4390 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752866Ab1K2Jnr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 04:43:47 -0500
In-Reply-To: <alpine.DEB.2.00.1111281821300.23758@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 18:33 -0800, Tom Herbert wrote:
> Changes to bnx2x to use byte queue limits.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   26 +++++++++++++++++++---
>  1 files changed, 22 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> index 8336c78..42ce566 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
> @@ -102,7 +102,8 @@ int load_count[2][3] = { {0} }; /* per-path: 0-common, 1-port0, 2-port1 */
>   * return idx of last bd freed
>   */
>  static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata,
> -			     u16 idx)
> +			     u16 idx, unsigned int *pkts_compl,
> +			     unsigned int *bytes_compl)
>  {
>  	struct sw_tx_bd *tx_buf = &txdata->tx_buf_ring[idx];
>  	struct eth_tx_start_bd *tx_start_bd;
> @@ -159,6 +160,10 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata,
>  
>  	/* release skb */
>  	WARN_ON(!skb);
> +	if (skb) {
likely statement will be usefull here, since we don't expect it to be
null

> +		(*pkts_compl)++;
> +		(*bytes_compl) += skb->len;
> +	}
