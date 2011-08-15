From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: suppress repeated error messages about Max
 BW
Date: Mon, 15 Aug 2011 13:54:40 +0300
Message-ID: <1313405680.31417.6.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20110812143324.5740.45824.stgit@dhcp-29-224.brq.redhat.com>
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
Received: from mms1.broadcom.com ([216.31.210.17]:3264 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab1HOKyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 06:54:55 -0400
In-Reply-To: <20110812143324.5740.45824.stgit@dhcp-29-224.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-08-12 at 07:33 -0700, Michal Schmidt wrote:
> When a VN is configured with invalid Max BW, the error does not have to
> be logged repeatedly and fill the logs.
> Warn only once when the bad configuration is detected on boot, or when
> the configuration changes dynamically from good to bad.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
> 
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    5 ++---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   21 +++++++++++----------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
>  4 files changed, 15 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> index c423504..648e165 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
> @@ -1220,6 +1220,7 @@ struct bnx2x {
>  	struct cmng_struct_per_port cmng;
>  	u32			vn_weight_sum;
>  	u32			mf_config[E1HVN_MAX];
> +	bool			prev_max_cfg_invalid[E1HVN_MAX];
The warning is always for the current VN, so if you insist on showing a
warning only once on a board with invalid configuration, you can use a
single boolean.

Thanks,
Eilon


