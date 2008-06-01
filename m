From: "Avuton Olrich" <avuton@gmail.com>
Subject: Re: atl1 card hibernation regression
Date: Sun, 1 Jun 2008 13:26:26 -0700
Message-ID: <3aa654a40806011326o2cfddfa0o6bc743041b5df8d6@mail.gmail.com>
References: <3aa654a40806010742s7529b9fxe02d0204f329065b@mail.gmail.com>
	 <20080601134120.3eb6651a@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@redhat.com>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Jay Cliburn" <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:40321 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbYFAU0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2008 16:26:32 -0400
Received: by gv-out-0910.google.com with SMTP id e6so86557gvc.37
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2008 13:26:28 -0700 (PDT)
In-Reply-To: <20080601134120.3eb6651a@osprey.hogchain.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 1, 2008 at 11:41 AM, Jay Cliburn <jacliburn@bellsouth.net> wrote:
> On Sun, 1 Jun 2008 07:42:02 -0700
> "Avuton Olrich" <avuton@gmail.com> wrote:
>
>> After resuming from hibernate, my network card refuses to get back
>> online. The bisection and much more information are below.
>
> Can you please try this patch?
>
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index 6e4c80d..1a2f93d 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -637,22 +637,6 @@ static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
>  }
>
>  /*
> - * Force the PHY into power saving mode using vendor magic.
> - */
> -#ifdef CONFIG_PM
> -static void atl1_phy_enter_power_saving(struct atl1_hw *hw)
> -{
> -       atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
> -       atl1_write_phy_reg(hw, MII_DBG_DATA, 0x124E);
> -       atl1_write_phy_reg(hw, MII_DBG_ADDR, 2);
> -       atl1_write_phy_reg(hw, MII_DBG_DATA, 0x3000);
> -       atl1_write_phy_reg(hw, MII_DBG_ADDR, 3);
> -       atl1_write_phy_reg(hw, MII_DBG_DATA, 0);
> -
> -}
> -#endif
> -
> -/*
>  * Resets the PHY and make all config validate
>  * hw - Struct containing variables accessed by shared code
>  *
> @@ -2859,7 +2843,6 @@ disable_wol:
>        ctrl |= PCIE_PHYMISC_FORCE_RCV_DET;
>        iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHYMISC);
>        ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
> -       atl1_phy_enter_power_saving(hw);
>        hw->phy_configured = false;
>        pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
>  exit:
>

Brilliant! Works as advertised, thanks for the quick fix!
-- 
avuton
--
 "I've got a fever. And the only prescription is more cowbell." --
Christopher Walken
