From: "Eugene T. Bordenkircher" <eugebo@gmail.com>
Subject: Problem with MDI/MDI-X auto-switching in E100 driver
Date: Thu, 22 Oct 2009 08:38:56 -0700
Message-ID: <4AE07C90.2080901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756575AbZJVPjP@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Around line 1466 of e100.c (git master) is the following code to turn on 
MDI/MDI-X auto-switching if it is not already.

         } else if ((nic->mac >= mac_82550_D102) || ((nic->flags & ich) &&
             (mdio_read(netdev, nic->mii.phy_id, MII_TPISTATUS) & 0x8000) &&
                  !(nic->eeprom[eeprom_cnfg_mdix] & eeprom_mdix_enabled))) {
                  /* enable/disable MDI/MDI-X auto-switching. */
                  mdio_write(netdev, nic->mii.phy_id, MII_NCONFIG,
                                  nic->mii.force_media ? 0 : NCONFIG_AUTO_SWITCH);
         }

This code is broken in the case where an 8255x is used without magnetics.  Per 
Intel Application note 435, without the magnetics, auto switching is not 
possible.  The only way to turn this off without driver modifications is to set 
the force_media flag via ethtool, which has the side effect of turning off all 
auto-negotiation. This happens to be the case on a product I am currently 
working on.

It seems a better solution to this is to trust the eeprom's configuration 
rather than override it.  Am I missing something or does this sound reasonable?

Eugene T. Bordenkircher
