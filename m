From: Joe Perches <joe@perches.com>
Subject: tg3 question: Why use misc_host_ctrl not pci_chip_rev_id here?
Date: Fri, 15 Feb 2013 14:41:16 -0800
Message-ID: <1360968076.21068.28.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35709 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751357Ab3BOWlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 17:41:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code is in the original 2002 tg3 commit from Jeff.
(line 15764 today)

static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
[]
	if ((pci_state_reg & PCISTATE_CONV_PCI_MODE) == 0 &&
	    !tg3_flag(tp, PCIX_TARGET_HWBUG)) {
(15764)		u32 chiprevid = GET_CHIP_REV_ID(tp->misc_host_ctrl)

		if (chiprevid == CHIPREV_ID_5701_A0 ||
		    chiprevid == CHIPREV_ID_5701_B0 ||
		    chiprevid == CHIPREV_ID_5701_B2 ||
		    chiprevid == CHIPREV_ID_5701_B5) {

This is the only test of GET_CHIP_REV_ID.

Shouldn't that GET_CHIP_REV_ID(tp->misc_host_ctrl)
and the tests below it be converted to tests like

	tp->pci_chip_rev_id == CHIPREV_ID_5701_A0

to be similar to all the pci_chip_rev_id tests that
the code in the same function uses?

It seems to me through a shallow reading that it's
the same value as tg3_detect_asic_rev() sets it.
