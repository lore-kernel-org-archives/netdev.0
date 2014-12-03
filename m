From: Hariprasad S <hariprasad@chelsio.com>
Subject: Re: [PATCH net] cxgb4: Add a check for flashing FW using ethtool
Date: Wed, 3 Dec 2014 13:37:42 +0530
Message-ID: <20141203080741.GA21760@hariprasad-pc>
References: <1417522177-14842-1-git-send-email-hariprasad@chelsio.com>
 <547DCA45.7060702@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<leedom@chelsio.com>, <anish@chelsio.com>, <nirranjan@chelsio.com>,
	<kumaras@chelsio.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7241 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbaLCIEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 03:04:42 -0500
Content-Disposition: inline
In-Reply-To: <547DCA45.7060702@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2014 at 17:18:45 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 12/2/2014 3:09 PM, Hariprasad Shenai wrote:
> 
> >Don't let T4 firmware flash on a T5 adapter and vice-versa
> >using ethtool
> 
> >Based on original work by Casey Leedom <leedom@chelsio.com>
> 
> >Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> >---
> >  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |   26 ++++++++++++++++++++++++++
> >  1 files changed, 26 insertions(+), 0 deletions(-)
> 
> >diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> >index 163a2a1..fae205a 100644
> >--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> >+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
> >@@ -1131,6 +1131,27 @@ unsigned int t4_flash_cfg_addr(struct adapter *adapter)
> >  		return FLASH_CFG_START;
> >  }
> >
> >+/* Return TRUE if the specified firmware matches the adapter.  I.e. T4
> >+ * firmware for T4 adapters, T5 firmware for T5 adapters, etc.  We go ahead
> >+ * and emit an error message for mismatched firmware to save our caller the
> >+ * effort ...
> >+ */
> >+static int t4_fw_matches_chip(const struct adapter *adap,
> 
>    s/int/bool/?
> 
> >+			      const struct fw_hdr *hdr)
> >+{
> >+	/* The expression below will return FALSE for any unsupported adapter
> >+	 * which will keep us "honest" in the future ...
> >+	 */
> >+	if ((is_t4(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T4) ||
> >+	    (is_t5(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T5))
> >+		return 1;
> 
>    s/1/true/?
> 
> >+
> >+	dev_err(adap->pdev_dev,
> >+		"FW image (%d) is not suitable for this adapter (%d)\n",
> >+		hdr->chip, CHELSIO_CHIP_VERSION(adap->params.chip));
> >+	return 0;
> 
>    s/0/false/?
> 
> [...]
> 
> WBR, Sergei
> 

Thanks for the review comment, have sent a V2 based on your comments.
