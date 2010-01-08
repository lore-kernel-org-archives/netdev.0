From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: RE: [PATCH] drivers/net/defxx.c: use %pMF to show MAC address
Date: Fri, 8 Jan 2010 18:58:02 +0000 (GMT)
Message-ID: <alpine.LFD.2.00.1001081838530.13474@eddie.linux-mips.org>
References: <201001071624.20139.hartleys@visionengravers.com>         <1262914750.10429.88.camel@Joe-Laptop.home>         <alpine.LFD.2.00.1001080143250.13474@eddie.linux-mips.org>         <BD79186B4FD85F4B8E60E381CAEE19090208961F@mi8nycmail19.Mi8.com>    
     <alpine.LFD.2.00.1001081316570.13474@eddie.linux-mips.org> <1262973254.14898.14.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:36663 "EHLO
	eddie.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753371Ab0AHS6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 13:58:05 -0500
Received: from localhost.localdomain ([127.0.0.1]:52123 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S1492849Ab0AHS6C (ORCPT
        <rfc822;netdev@vger.kernel.org> + 1 other);
        Fri, 8 Jan 2010 19:58:02 +0100
In-Reply-To: <1262973254.14898.14.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Jan 2010, Joe Perches wrote:

> >  Here are excerpts from old bootstrap logs -- I don't have any of these 
> > boards handy at the moment, but I'll have access to a couple in a few 
> > weeks' time:
> > 
> > defxx: v1.10 2006/12/14  Lawrence V. Stefani and others
> > tc0: DEFTA at addr = 0x10100000, IRQ = 2, Hardware addr = 08-00-2B-A3-66-C8
> > tc0: registered as fddi0
> > tc1: DEFTA at addr = 0x14100000, IRQ = 3, Hardware addr = 08-00-2B-A3-A3-29
> > tc1: registered as fddi1
> > 
> > defxx: v1.10 2006/12/14  Lawrence V. Stefani and others
> > 0000:00:06.0: DEFPA at addr = 0x41071000, IRQ = 57, Hardware addr = 00-60-B0-58-40-75
> > 0000:00:06.0: registered as fddi0
> > 0000:02:00.0: DEFPA at addr = 0x41510000, IRQ = 57, Hardware addr = 00-60-B0-58-41-E7
> > 0000:02:00.0: registered as fddi1
> > 
> > Compare the addresses reported with the OUIs of the respective 
> > manufacturers -- the former is DEC and the latter is HP.  See 
> > http://standards.ieee.org/regauth/oui/oui.txt for a reference.
> 
> Then isn't the hardware address shown as ethernet and not as
> in the FDDI canonical format?
> 
> Which confuses me relative to what you wrote earlier.

 It's shown in the FDDI canonical form, so it should use dashes as 
separators.  That's been my point from the very beginning.

> > On Mon, 2010-01-04 at 23:43 +0000, Maciej W. Rozycki wrote:
> > > The example below shows an address, and the sequence of bits or symbols 
> > > that would be transmitted when the address is used in the Source Address 
> > > or Destination Address fields on the MAC header.  The transmission line 
> > > shows the address bits in the order transmitted, from left to right.  For 
> > > IEEE 802 LANs these correspond to actual bits on the medium.  The FDDI 
> > > symbols line shows how the FDDI PHY sends the address bits as encoded 
> > > symbols.
> > > 
> > >         MSB:            35:7B:12:00:00:01
> > >         Canonical:      AC-DE-48-00-00-80
> 
> So, it should simply use %pM correct?

 No.  The %pM specifier would print the hex numbers in the canonical form, 
but still use the MSB form separator and therefore confuse the reader who 
would normally conclude from the separators that the address is actually 
in the MSB form.

> Is there any address that should be shown in the
> FDDI canonical form?

 All are typically shown in that form.

 WRT the DEFxx boards: the firmware presents and expects addresses 
communicated with the OS in the canonical form (they are bitswapped in 
hardware by appropriate circuitry I believe).  However if data contained 
within SMT management frames (normally out of interest and not passed to 
the OS, but can be received if the appropriate promiscuous mode is 
selected) is examined, then addresses embedded within are in the (native) 
MSB form (SMT is low-bandwidth traffic, so software processing overhead is 
not critical).  That's I believe the reason both forms are used in the 
first place and the possible source of confusion.

 Please let me know if I've been clear enough this time.

  Maciej
