From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: APIC error on 32-bit kernel
Date: Sat, 12 May 2007 09:24:13 -0500
Message-ID: <20070512092413.4911f71b@osprey.hogchain.net>
References: <20070323200817.1f3e39b9@osprey.hogchain.net>
	<20070408133822.3868e6ff@osprey.hogchain.net>
	<200705112328.58927.lenb@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Len Brown <lenb@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf22aec.mail.bellsouth.net ([205.152.59.70]:33657 "EHLO
	imf22aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754285AbXELOYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 10:24:16 -0400
In-Reply-To: <200705112328.58927.lenb@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you very much for looking at this, Len.


On Fri, 11 May 2007 23:28:58 -0400
Len Brown <lenb@kernel.org> wrote:

> > > [   94.754852] APIC error on CPU0: 08(40)
> > > [   94.806045] APIC error on CPU0: 40(08)
> 
>         /* Here is what the APIC error bits mean:
>            0: Send CS error
>            1: Receive CS error
>            2: Send accept error
>            3: Receive accept error
>            4: Reserved
>            5: Send illegal vector
>            6: Received illegal vector
>            7: Illegal register address
>         */
> 
> So the 40 means the APIC got an illegal vector.
> Certainly this is consistent with the fact that
> the errors start when a specific device is being
> used.  I assume that device is using MSI?

Yes, the device is using MSI.

> Curious that it is different in 32-bit and 64-bit mode.

Agreed, although I had one user back in March report APIC errors on the
Asus M2V board while running Debian x86_64.  I personally have never
encountered the problem under a 64-bit kernel, but I admit that just
might be random luck.


> > > We also do not see this problem on Intel-based motherboards, with
> > > either 32- or 64-bit kernels.
> > 
> > A full raft of documentation -- including acpidump and
> > linux-firmware-kit output, console capture, kernel config, lspci
> > -vvxxx (with apic=debug boot option), dmesg, and /proc/interrupts
> > -- is available at http://www.hogchain.net/m2v/apic-problem/
> 
> 
> [06Dh 109  2]      Boot Architecture Flags : 0003
> 
> for what it is worth, the bit in ACPI that is used to
> disable MSI support is not set -- so as  far as the BIOS
> is concerned, this system should support MSI.
> 
> Is it an add-in card, or lan-on-motherboard?

This is a PCIe LAN-on-motherboard.

My goal is to understand whether this is a problem in the atl1 driver,
or a problem on the motherboard.  If it's the former, obviously I want
to fix it.  If it's the latter, then I want to disable MSI in the driver
when we discover we're running on this motherboard.

Thanks again for taking time to look at this.  Any advice or hints you
provide will be greatly appreciated.

Jay
