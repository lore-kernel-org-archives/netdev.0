From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.23-rc1 sky2 boot crash in sky2_mac_intr
Date: Tue, 24 Jul 2007 09:50:08 +0100
Message-ID: <20070724095008.0eb154fe@oldman.hamilton.local>
References: <20070724082205.GA19480@paradigm.rfc822.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Lohoff <flo@rfc822.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51047 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758812AbXGXIva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 04:51:30 -0400
In-Reply-To: <20070724082205.GA19480@paradigm.rfc822.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Jul 2007 10:22:05 +0200
Florian Lohoff <flo@rfc822.org> wrote:

> 
> Hi,
> i am seeing irregular crashes on boot in the sky2_mac_intr. This is an
> Fujitsu Siemens Lifebook E8110 with a Core Duo. Currently i suspect some
> strange BIOS issues as the issues i see with the sky2 aka parity errors
> etc i also see sometimes with the integrated ipw3945 which complains
> about firmware errors. It seems the BIOS randomly fails to initialize
> all the hardware. To reproduce this crash and catch it on the serial
> console it took me around 12 boots. The machine is stable once correctly
> booted and i work most of the day on it.
> 
> [   46.479939] ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 19
> [   46.568569] sky2 0000:02:00.0: v1.16 addr 0xf0000000 irq 19 Yukon-EC Ultra (0xb4) rev 2
> [   46.664555] sky2 eth0: addr 00:17:42:13:45:8c
> 
> [   61.958741] sky2 eth1: enabling interface
> [   62.010834] sky2 eth1: phy write timeout

The problem is related to power management. The PHY has a number of PCI configuration
registers for power control, and the function of these changes based on the version and
revision of the chip. The driver does work on older versions of the EC-U, in
Fujitsu laptop's, it is just the new rev that is broken.

The driver should probably fail smarter (by not loading) if the PHY isn't powered
up correctly, but that doesn't help your problem.

The vendor has provided me with documentation on many versions
of the chip, but I don't have doc's on the lastest revision differences of the EC Ultra, 
so a proper solution is not easily available.  The best method for resolving this would
be to first try the vendor driver version of sk98lin and see if that fixes it. If so,
then it is easy to change sky2, to match the phy setup in the vendor driver.
Another possibility is to look for places in sky2 driver where there are places
that compare version/revision.

The most likely bits that need to change are in PCI registers: 0x80, 0x84 and 0x88
You could also load the windows driver and dump PCI config space (with lspci from
cygwin), and see what the settings are there.

I am away from my office for a month, and therefore away from any sky2
hardware for testing. 

