From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next 03/12] drivers: net: xgene: Use rgmii mdio mac
 access
Date: Wed, 10 May 2017 14:48:36 -0700
Message-ID: <4be54921-2d46-1675-9f39-894c7caf3807@gmail.com>
References: <1494449110-23785-1-git-send-email-isubramanian@apm.com>
 <1494449110-23785-4-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Quan Nguyen <qnguyen@apm.com>, patches@apm.com,
        linux-arm-kernel@lists.infradead.org
To: Iyappan Subramanian <isubramanian@apm.com>, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:36612 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751182AbdEJVsk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 17:48:40 -0400
Received: by mail-qk0-f193.google.com with SMTP id y128so1285311qka.3
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 14:48:39 -0700 (PDT)
In-Reply-To: <1494449110-23785-4-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 01:45 PM, Iyappan Subramanian wrote:
> From: Quan Nguyen <qnguyen@apm.com>
> 
> This patch switches to use rgmii mdio mac access routines if available,
> as they share the same HW.
> 
> Signed-off-by: Quan Nguyen <qnguyen@apm.com>
> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> index 2050c58..47c5b75 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> @@ -277,6 +277,13 @@ void xgene_enet_wr_mac(struct xgene_enet_pdata *pdata, u32 wr_addr, u32 wr_data)
>  	u8 wait = 10;
>  	u32 done;
>  
> +	if (pdata->mdio_driver && ndev->phydev &&
> +	    pdata->phy_mode == PHY_INTERFACE_MODE_RGMII) {

To be on the safe side you should check all 4 values of
PHY_INTERFACE_MODE_RGMII, not just this one.
-- 
Florian
