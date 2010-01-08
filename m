From: Joe Perches <joe@perches.com>
Subject: RE: [PATCH] drivers/net/defxx.c: use %pMF to show MAC address
Date: Fri, 08 Jan 2010 09:54:14 -0800
Message-ID: <1262973254.14898.14.camel@Joe-Laptop.home>
References: <201001071624.20139.hartleys@visionengravers.com>
	 <1262914750.10429.88.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1001080143250.13474@eddie.linux-mips.org>
	 <BD79186B4FD85F4B8E60E381CAEE19090208961F@mi8nycmail19.Mi8.com>
	 <alpine.LFD.2.00.1001081316570.13474@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, davem@davemloft.net
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1660 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752662Ab0AHRyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 12:54:16 -0500
In-Reply-To: <alpine.LFD.2.00.1001081316570.13474@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-08 at 13:34 +0000, Maciej W. Rozycki wrote:
> On Thu, 7 Jan 2010, H Hartley Sweeten wrote:
> > >> I believe the output will _now_ be in the canonical form.
> > >> Before it wasn't bit reversed.  Now it should be.
> > >
> > > Output was correct -- why would you assume otherwise?
> > > With the two patches in place the output produced is now broken. :(

>  Here are excerpts from old bootstrap logs -- I don't have any of these 
> boards handy at the moment, but I'll have access to a couple in a few 
> weeks' time:
> 
> defxx: v1.10 2006/12/14  Lawrence V. Stefani and others
> tc0: DEFTA at addr = 0x10100000, IRQ = 2, Hardware addr = 08-00-2B-A3-66-C8
> tc0: registered as fddi0
> tc1: DEFTA at addr = 0x14100000, IRQ = 3, Hardware addr = 08-00-2B-A3-A3-29
> tc1: registered as fddi1
> 
> defxx: v1.10 2006/12/14  Lawrence V. Stefani and others
> 0000:00:06.0: DEFPA at addr = 0x41071000, IRQ = 57, Hardware addr = 00-60-B0-58-40-75
> 0000:00:06.0: registered as fddi0
> 0000:02:00.0: DEFPA at addr = 0x41510000, IRQ = 57, Hardware addr = 00-60-B0-58-41-E7
> 0000:02:00.0: registered as fddi1
> 
> Compare the addresses reported with the OUIs of the respective 
> manufacturers -- the former is DEC and the latter is HP.  See 
> http://standards.ieee.org/regauth/oui/oui.txt for a reference.

Then isn't the hardware address shown as ethernet and not as
in the FDDI canonical format?

Which confuses me relative to what you wrote earlier.

> On Mon, 2010-01-04 at 23:43 +0000, Maciej W. Rozycki wrote:
> > The example below shows an address, and the sequence of bits or symbols 
> > that would be transmitted when the address is used in the Source Address 
> > or Destination Address fields on the MAC header.  The transmission line 
> > shows the address bits in the order transmitted, from left to right.  For 
> > IEEE 802 LANs these correspond to actual bits on the medium.  The FDDI 
> > symbols line shows how the FDDI PHY sends the address bits as encoded 
> > symbols.
> > 
> >         MSB:            35:7B:12:00:00:01
> >         Canonical:      AC-DE-48-00-00-80

So, it should simply use %pM correct?

Is there any address that should be shown in the
FDDI canonical form?

cheers, Joe

