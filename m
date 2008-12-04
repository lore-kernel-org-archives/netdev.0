From: Michael Brown <mbrown@fensystems.co.uk>
Subject: Re: Realtek 8169 problems with net booting
Date: Thu, 4 Dec 2008 17:22:26 +0000
Message-ID: <200812041722.26935.mbrown@fensystems.co.uk>
References: <20081124181456.66a967d2@lxorguk.ukuu.org.uk> <20081124.135710.83221715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprocket.fensystems.co.uk ([212.13.204.53]:33033 "EHLO
	sprocket.fensystems.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195AbYLDRuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 12:50:10 -0500
In-Reply-To: <20081124.135710.83221715.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 24 November 2008 21:57:10 David Miller wrote:
> Yes, a lot of drivers will enable bus mastering before resetting
> the chip.
>
> The basic assumption is that the chip is quiescent at driver load
> time.
>
> Since switching around this order across the board is too
> gigantic a project, I would suggest just handling things on
> a case-by-case basis where we know the BIOS or firmware leave
> the chip in a crud state like this.

The assumption that the chip is quiescent is invalid in the case of any kind 
of boot from SAN (e.g. iSCSI, AoE) via the net device.  The INT13-based 
bootloader has no way to signal to the boot firmware that it is finished 
using the INT13 interface, so the card will always be left in an active 
state.

In gPXE, we do what we can to ensure that the card is safe to use when the OS 
loads; we edit the RX buffers, ISR, etc. out of the system memory map prior 
to starting an iSCSI boot.  We don't, however, get a chance to actually 
quiesce the chip before the OS driver loads up, so the OS driver must be 
prepared to discover the chip in an active state.

Michael
