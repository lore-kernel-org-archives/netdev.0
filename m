From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 question: Why use misc_host_ctrl not pci_chip_rev_id
 here?
Date: Sat, 16 Feb 2013 12:54:17 -0800
Message-ID: <1361048057.2240.1.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1360968076.21068.28.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, "Jeff Garzik" <jeff@garzik.org>,
	"David Miller" <davem@davemloft.net>,
	"Matt Carlson" <mcarlson@broadcom.com>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1305 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753065Ab3BPUy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 15:54:28 -0500
In-Reply-To: <1360968076.21068.28.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 14:41 -0800, Joe Perches wrote: 
> This code is in the original 2002 tg3 commit from Jeff.
> (line 15764 today)
> 
> static int tg3_get_invariants(struct tg3 *tp, const struct pci_device_id *ent)
> []
> 	if ((pci_state_reg & PCISTATE_CONV_PCI_MODE) == 0 &&
> 	    !tg3_flag(tp, PCIX_TARGET_HWBUG)) {
> (15764)		u32 chiprevid = GET_CHIP_REV_ID(tp->misc_host_ctrl)
> 
> 		if (chiprevid == CHIPREV_ID_5701_A0 ||
> 		    chiprevid == CHIPREV_ID_5701_B0 ||
> 		    chiprevid == CHIPREV_ID_5701_B2 ||
> 		    chiprevid == CHIPREV_ID_5701_B5) {
> 
> This is the only test of GET_CHIP_REV_ID.
> 
> Shouldn't that GET_CHIP_REV_ID(tp->misc_host_ctrl)
> and the tests below it be converted to tests like
> 
> 	tp->pci_chip_rev_id == CHIPREV_ID_5701_A0
> 
> to be similar to all the pci_chip_rev_id tests that
> the code in the same function uses?

Yes, I agree with you that the 2 methods are the same and we should make
everything consistent.  Thanks.
