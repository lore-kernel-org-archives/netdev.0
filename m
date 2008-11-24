From: David Miller <davem@davemloft.net>
Subject: Re: Realtek 8169 problems with net booting
Date: Mon, 24 Nov 2008 13:57:10 -0800 (PST)
Message-ID: <20081124.135710.83221715.davem@davemloft.net>
References: <20081124181456.66a967d2@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53530
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752925AbYKXV5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:57:10 -0500
In-Reply-To: <20081124181456.66a967d2@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Mon, 24 Nov 2008 18:14:56 +0000

> 8169 does this
> 
> 	pci_set_master
> 	twiddle a few bits
> 	soft reset chip
> 
> The master bit is off when the driver is loaded it appears but surely the
> driver should do
> 
> 	twiddle a few bits
> 	soft reset chip
> 	pci_set_master
> 
> otherwise it has no idea if a warm boot from Linux without neat shutdown,
> or a BIOS tftp has left the chip trying to spew into main memory ?

Yes, a lot of drivers will enable bus mastering before resetting
the chip.

The basic assumption is that the chip is quiescent at driver load
time.

Since switching around this order across the board is too
gigantic a project, I would suggest just handling things on
a case-by-case basis where we know the BIOS or firmware leave
the chip in a crud state like this.
