From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: [PATCH v1 net-next 1/2] igb: add PHY support for Broadcom 5461S
Date: Thu, 7 May 2015 09:18:00 -0700
Message-ID: <CAJ+vNU0NP4Lmc2=y_j9NN0AxK1pUTPs8rSNJ78SCp4CBQ6wtMg@mail.gmail.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
	gospo@cumulusnetworks.com, shm@cumulusnetworks.com,
	Alan Liebthal <alanl@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:34916 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbEGQSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 12:18:02 -0400
Received: by qcbgu10 with SMTP id gu10so23641763qcb.2
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 09:18:01 -0700 (PDT)
In-Reply-To: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2015 at 1:23 PM, Jonathan Toppins
<jtoppins@cumulusnetworks.com> wrote:
> From: Alan Liebthal <alanl@cumulusnetworks.com>
>
> The Quanta LY8 Ethernet management port uses a Broadcom 5461S chip for
> the PHY layer. This adds support for this PHY to the Intel igb driver.
>
> Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> ---
<snip>
> --- a/drivers/net/ethernet/intel/igb/e1000_phy.c
> +++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
> @@ -148,6 +148,13 @@ s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
>          * Control register.  The MAC will take care of interfacing with the
>          * PHY to retrieve the desired data.
>          */
> +       if (phy->type == e1000_phy_bcm5461s) {
> +               mdic = rd32(E1000_MDICNFG);
> +               mdic &= ~E1000_MDICNFG_PHY_MASK;
> +               mdic |= (phy->addr << E1000_MDICNFG_PHY_SHIFT);
> +               wr32(E1000_MDICNFG, mdic);
> +       }
> +
>         mdic = ((offset << E1000_MDIC_REG_SHIFT) |
>                 (phy->addr << E1000_MDIC_PHY_SHIFT) |
>                 (E1000_MDIC_OP_READ));
> @@ -204,6 +211,13 @@ s32 igb_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
>          * Control register.  The MAC will take care of interfacing with the
>          * PHY to retrieve the desired data.
>          */
> +       if (phy->type == e1000_phy_bcm5461s) {
> +               mdic = rd32(E1000_MDICNFG);
> +               mdic &= ~E1000_MDICNFG_PHY_MASK;
> +               mdic |= (phy->addr << E1000_MDICNFG_PHY_SHIFT);
> +               wr32(E1000_MDICNFG, mdic);
> +       }
> +
>         mdic = (((u32)data) |
>                 (offset << E1000_MDIC_REG_SHIFT) |
>                 (phy->addr << E1000_MDIC_PHY_SHIFT) |
> @@ -2509,3 +2523,68 @@ static s32 igb_set_master_slave_mode(struct e1000_hw *hw)
>
>         return hw->phy.ops.write_reg(hw, PHY_1000T_CTRL, phy_data);
>  }

Jonathan,

Is this bcm5461s attached to an i210/i211? These changes look a lot
like some changes I'm trying to upstream to add support for i210/i211
which require the phy address in the MDICNFG register. If this is the
case, then I think the right approach is to check for hw->mac.type =
e1000_i210/e1000_i211 and I can submit my patch for review.

Regards,

Tim
