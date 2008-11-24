From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Realtek 8169 problems with net booting
Date: Mon, 24 Nov 2008 18:14:56 +0000
Message-ID: <20081124181456.66a967d2@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:44668 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752804AbYKXSOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 13:14:44 -0500
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by lxorguk.ukuu.org.uk (8.14.2/8.14.2) with ESMTP id mAOIEu2U032590
	for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 18:14:56 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On one box here it has always been the case that now and then the boot
with crash just after r8169 is loaded iff the BIOS network rom (ie the
dhcp stuff) is enabled. Its erratic, hard to reproduce but I finally got
around to looking at the driver and have a question that seems to apply
to several network drivers

8169 does this

	pci_set_master
	twiddle a few bits
	soft reset chip

The master bit is off when the driver is loaded it appears but surely the
driver should do

	twiddle a few bits
	soft reset chip
	pci_set_master

otherwise it has no idea if a warm boot from Linux without neat shutdown,
or a BIOS tftp has left the chip trying to spew into main memory ?

Alan


