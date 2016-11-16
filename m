From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: [PATCH 1/1] ixgbe: write flush vfta registers
Date: Wed, 16 Nov 2016 15:05:44 +0100
Message-ID: <trinity-ec3a2e6f-7310-41aa-8743-61bc62ccf663-1479305144399@3capp-gmx-bs59>
References: <1479300041-3436-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        "Zhu Yanjun" <zyjzyj2000@gmail.com>
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:56312 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751955AbcKPOGH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 09:06:07 -0500
In-Reply-To: <1479300041-3436-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi,

> 
> Sometimes vfta registers can not be written successfully in dcb mode.
> This is very occassional. When the ixgbe nic runs for a very long time,
> sometimes this bug occurs. But after IXGBE_WRITE_FLUSH is executed,
> this bug never occurs.
> 
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index bd93d82..1221cfb 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -4138,8 +4138,10 @@ static void ixgbe_vlan_promisc_enable(struct ixgbe_adapter *adapter)
>  	}
>  
>  	/* Set all bits in the VLAN filter table array */
> -	for (i = hw->mac.vft_size; i--;)
> +	for (i = hw->mac.vft_size; i--;) {
>  		IXGBE_WRITE_REG(hw, IXGBE_VFTA(i), ~0U);
> +		IXGBE_WRITE_FLUSH(hw);
> +	}

Should it not be sufficient to do the flush only once, at the end of the function?

Regards,
Lino
