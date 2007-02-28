From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 4/5] r8169: more alignment for the 0x8168
Date: Thu, 1 Mar 2007 00:18:54 +0100
Message-ID: <20070228231854.GA31596@electric-eye.fr.zoreil.com>
References: <20061203235257.GA3625@electric-eye.fr.zoreil.com> <20061204000327.GE3625@electric-eye.fr.zoreil.com> <45D13578.8040405@snapgear.com> <20070213081439.GA21261@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0702131730570.14346@cnc.isely.net> <20070223231355.GA10930@electric-eye.fr.zoreil.com> <45E28F63.8000208@snapgear.com> <20070228214839.GA23772@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philip Craig <philipc@snapgear.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: Mike Isely <isely@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52739 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222AbXB1X0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 18:26:08 -0500
Content-Disposition: inline
In-Reply-To: <20070228214839.GA23772@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
[...]

The experimental r8169 patch of the day against 2.6.21-rc2 is available at:
http://www.fr.zoreil.com/linux/www.fr.zoreil.com/people/francois/misc/20070228-2.6.21-rc2-r8169-test.patch
(single patch)

or:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc2
(series)

Log below:

commit 6686d80d6972cd5ff3ca81b72c46f4ffcc40eb4c
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Wed Feb 28 23:16:57 2007 +0100

    r8169: align the IP header when there is no DMA constraint
    
    Align the IP header when the chipset can DMA at any location (plain 0x8169).
    Otherwise (0x8136/0x8168) obey the constraint imposed by the hardware.
    
    This patch complements the previous alignment rework done for copybreak.
    
    Original idea from Philip Craig <philipc@snapgear.com>
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Philip Craig <philipc@snapgear.com>
    Cc: Mike Isely <isely@pobox.com>

commit d20a6ba195172f7fb9fd30832a054effb9773bc3
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Fri Feb 23 23:50:28 2007 +0100

    r8169.c: add bit description for the TxPoll register
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit 37dc1270eba2874a00564abe0d857429af5370f2
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Fri Feb 23 23:24:55 2007 +0100

    r8169: MSI support
    
    It is currently limited to 0x8136 and 0x8168. 8169sb/8110sb ought to
    handle it as well where they support MSI.
    
    Includes unregister_netdev() fix from Bernhard Walle <bwalle@suse.de>
    against BUG_ON(irq_has_action(dev->first_msi_irq)) (2007/02/24).
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Fixed-by: Bernhard Walle <bernhard.walle@gmx.de>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit b388fb659dc5803cdb2293649e25807f88ba94ec
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Wed Feb 21 22:40:46 2007 +0100

    r8169: cleanup
    
    No functionnal change:
    - trim the old history log
    - whitespace/indent/case police
    - unsigned int where signedness does not matte
    - removal of obsolete assert
    - needless cast from void * (dev_instance)
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit 090121a1d8b9452fd454fa44ba67d9761a6e8f1e
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Wed Feb 21 00:10:20 2007 +0100

    r8169: remove the media option
    
    It has been documented as deprecated:
    - in MODULE_PARM_DESC since may 2005 ;
    - at the top of the source file and in printk since june 2004.
    
    Good bye.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit 5231dd72b4d9551c6cd8baa9b7026a1f21b12052
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Tue Feb 20 22:58:51 2007 +0100

    r8169: small 8101 comment
    
    Extracted from version 1.001.00 of Realtek's r8101.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit 20be52f668774727ba1d1a3606cc2888f66d40bf
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Tue Feb 20 22:20:51 2007 +0100

    r8169: confusion between hardware and IP header alignment
    
    The rx copybreak part is straightforward.
    
    The align field in struct rtl_cfg_info is related to the alignment
    requirements of the DMA operation. Its value is set at 2 to limit the
    scale of possible regression but my old v1.21 8169 datasheet claims a
    8 bytes requirements (that was never followed by the driver of course)
    and the 8101/8168 go with a plain 8 bytes alignments. Yuck...
    
    /me waits for the attack of ballistic vegetables...
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit b0ee36861173a3ac57017c8a3850ad21a4c1acf6
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Tue Feb 20 00:00:26 2007 +0100

    r8169: merge with version 8.001.00 of Realtek's r8168 driver
    
    This one includes:
    
    - more tweaks to rtl_hw_start_8168
    
    - a work around for a Rx FiFO overflow issue on the 8168Bb
      + rtl8169_{intr_mask/napi_event} are replaced with per-device fields
      + rtl_cfg_info is converted to C99 for readability but the values are
        not changed for the 8169/8110 and the 8101
    
    Includes ChipCmd fix from Bernhard Walle <bwalle@suse.de> (2007/02/24).
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit 9d4139624a1c2ae138ea043083263c84d14bbd3a
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Tue Feb 13 23:38:05 2007 +0100

    r8169: merge with version 6.001.00 of Realtek's r8169 driver
    
    - new identifier for the 8110SCe ;
    
    - the PCI latency timer is set unconditionally. This part is identical
      in Realtek's r8168 (8.001.00) and r8101 (1.001.00) ;
    
    - initialization of the cache line size register is for the 8169s only ;
    - more magic in rtl_hw_start_8169 ;
    
    - it is not possible to factor out the setting of the the irq event mask
      with the 8168 and the 8101 any more. Pushed it into the hw_start handler ;
    
    - rtl_set_rx_tx_config_registers() and write to the ChipCmd register are
      issued identically for the whole 8169/8110 family: the 8110SCd/8110SCe
      make no more difference ;
    
    - work around for AMD platform.
    
    I let aside some registers definitions for later.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit 7b6de0565fb48bb2a7a998c5f1e80d1301a9c14a
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Tue Feb 13 22:30:50 2007 +0100

    r8169: add per-device hw_start handler (2/2)
    
    Part 2: populate the hw_start handlers for the 8168 and the 8101.
    
    - annotate mac_version
    - factor out the initialization of the receive and transmit ring
      descriptor registers (rtl_set_rx_tx_desc_registers)
    - access to the CPlusCmd and setting of the maximum receive size are
      idiomatic too (rtl_rw_cpluscmd and rtl_set_rx_max_size)
    
    Each chipset should run through the same code as before in its
    dedicated hw_start handler.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit f33de543281a3fbe2e15ad482b746b3a21f1d865
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Fri Feb 23 23:36:39 2007 +0100

    r8169: add per-device hw_start handler (1/2)
    
    rtl8169_hw_start will not help maintaining an unified driver for
    different chipsets but people at Realtek are probably too polite
    to say it distinctly.
    
    Part 1: add the hook and keep hw_start handler unchanged.
    
    As can be seen from the content of rtl8169_pci_tbl, the RTL_CFG_1
    entry in rtl_cfg_info was unused. I recycled it for the 0x8168.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>

commit bf52169682e73b43ddd58608c981e39932db7174
Author: Jeff Garzik <jeff@garzik.org>
Date:   Sun Feb 11 22:50:31 2007 +0100

    r8169: fix a race between PCI probe and dev_open
    
    Initialize the timer with the rest of the private-struct.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Edward Hsu <edward_hsu@realtek.com>
