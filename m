From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: downgrade Max BW error message to debug
Date: Wed, 17 Aug 2011 20:44:15 +0300
Message-ID: <1313603055.12483.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20110812143324.5740.45824.stgit@dhcp-29-224.brq.redhat.com>
 <1313405680.31417.6.camel@lb-tlvb-eilong.il.broadcom.com>
 <4E490A1E.3060209@redhat.com>
 <1313411585.31417.35.camel@lb-tlvb-eilong.il.broadcom.com>
 <4E493798.7010405@redhat.com>
 <1313434042.30399.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <4E4A56C0.4030009@redhat.com>
 <1313498708.24298.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <20110817175037.2777724a@brian.englab.brq.redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "Michal Schmidt" <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2585 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751202Ab1HQRoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2011 13:44:34 -0400
In-Reply-To: <20110817175037.2777724a@brian.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-17 at 08:50 -0700, Michal Schmidt wrote:
> There are valid configurations where Max BW is configured to zero for
> some VNs.
> Print the message only if debugging is enabled and do not call the
> configuration "illegal".
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
> index 223bfee..8245e02 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
> @@ -1481,8 +1481,7 @@ static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, u32 mf_cfg)
>  	u16 max_cfg = (mf_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
>  			      FUNC_MF_CFG_MAX_BW_SHIFT;
>  	if (!max_cfg) {
> -		BNX2X_ERR("Illegal configuration detected for Max BW - "
> -			  "using 100 instead\n");
> +		BNX2X_DBG_ERR("Max BW configured to 0 - using 100 instead\n");
I think that we should use DP instead of DBG_ERR. How about this one:

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 223bfee..70dc7bc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1481,8 +1481,7 @@ static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, u32 mf_cfg)
 	u16 max_cfg = (mf_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
 			      FUNC_MF_CFG_MAX_BW_SHIFT;
 	if (!max_cfg) {
-		BNX2X_ERR("Illegal configuration detected for Max BW - "
-			  "using 100 instead\n");
+		DP(NETIF_MSG_LINK, "Max BW configured to 0 - using 100 instead\n");
 		max_cfg = 100;
 	}
 	return max_cfg;


Can you sing-off on somethign like this?

Thanks,
Eilon


