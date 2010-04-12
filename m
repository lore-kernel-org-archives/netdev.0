From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002) on
	DEC Alpha Personal Workstation 433au
Date: Sun, 11 Apr 2010 21:44:52 -0600
Message-ID: <20100412034452.GA22957@lackof.org>
References: <20100405171318.GA18915@physik.fu-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:55435 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655Ab0DLDox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 23:44:53 -0400
Content-Disposition: inline
In-Reply-To: <20100405171318.GA18915@physik.fu-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 05, 2010 at 07:13:18PM +0200, Adrian Glaubitz wrote:
> Hi guys,
> 
> I installed Debian unstable on an old digital workstation "DEC Digital
> Personal Workstation 433au" (Miata) which has an on-board tulip
> network controller. I'm not really using that network controller but
> an off-board intel e1000 controller. However, I found that the tulip
> driver produces a lot of noise in the message log, the following
> message is repated periodically and spams the whole message log:
> 
> 0000:00:03.0: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002)
> 
> Do you think this is related to the fact that no cable is connected to
> the network controller?

It shouldn't be. The "stop_rxtx failed" error is because either 
CSR5_TS or CSR5_RS are still set in CSR5. This means the chip
thinks the transmit or receive protocol engines are still running.

What I suspect is the state isn't "running" by rather some other
"hung" state caused by failed (lack of) link. This has been reported
before but I've not looked that closely yet.

> The lspci output of the hardware looks like this:
> 
> test-adrian1:~# lspci
> 00:03.0 Ethernet controller: Digital Equipment Corporation DECchip 21142/43 (rev 30)
> 00:07.0 ISA bridge: Contaq Microsystems 82c693
> 00:07.1 IDE interface: Contaq Microsystems 82c693
> 00:07.2 IDE interface: Contaq Microsystems 82c693
> 00:07.3 USB Controller: Contaq Microsystems 82c693
> 00:0b.0 VGA compatible controller: Matrox Graphics, Inc. MGA 2064W [Millennium] (rev 01)
> 00:14.0 PCI bridge: Digital Equipment Corporation DECchip 21152 (rev 03)
> 01:04.0 SCSI storage controller: QLogic Corp. ISP1020 Fast-wide SCSI (rev 05)
> 01:09.0 Ethernet controller: Intel Corporation 82541GI Gigabit Ethernet Controller
> 
> If you need anymore verbose or debug output, please let me know.

I might. I first have to stare at the tulip programmers guide a while
sort.

cheers,
grant
