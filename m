From: Julia Lawall <julia@diku.dk>
Subject: question about drivers/net/tg3.c
Date: Wed, 29 Jul 2009 17:49:35 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907291743300.22045@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:38451 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754074AbZG2PyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2009 11:54:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function tg3_reset_hw in the file drivers/net/tg3.c contains the code:

	/* If statement applies to 5705 and 5750 PCI devices only */
	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
             tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) ||
	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750) {
                if ((tp->tg3_flags & TG3_FLG2_TSO_CAPABLE) &&
                    (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 ||
	             tp->pci_chip_rev_id == CHIPREV_ID_5705_A2)) {
	                /* nothing */
	        } else if (!(tr32(TG3PCI_PCISTATE) & PCISTATE_BUS_SPEED_HIGH) &&
	                   !(tp->tg3_flags2 & TG3_FLG2_IS_5788) &&
			   !(tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS)) {
			val |= WDMAC_MODE_RX_ACCEL;
	        }
	}


On the fifth line above there is the code:

tp->tg3_flags & TG3_FLG2_TSO_CAPABLE

but the tg3_flags field seems to normally have a value whose name contains 
FLAG, and not FLG2.  Should this code be:

tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE

or should the constant be different?

julia
