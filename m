From: Tom Rini <trini@kernel.crashing.org>
Subject: Problem with 3c59x, WOL and Intel 440LX/EX or 430TX
Date: Wed, 11 Feb 2004 10:07:27 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040211170727.GC18571@smtp.west.cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Mason <chris@k-rad.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hello.  I believe I have tracked down a problem with the WOL support in
the 3c59x driver (2.6 varriant only right now).  The problem has been
seen I belive by a few people:
(my own reports)
http://marc.theaimsgroup.com/?l=linux-kernel&m=106297008218993&w=2
http://lkml.org/lkml/2003/9/2/167

I believe that the problem here is not with the driver per-se but with
the BIOS:
http://www.asus.com.tw/download/mbdriver/slot1-440lx.htm

The short description of the problem is that when the WOL code in the
driver is enabled, on some presumably buggy BIOSes the card ends up
getting put into the sleep state, or something as something like the
following gets reported as the driver inits:
3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
See Documentation/networking/vortex.txt
0000:00:0e.0: 3Com PCI 3c905B Cyclone 100baseTx at 0xe480. Vers LK1.1.19
PCI: Setting latency timer of device 0000:00:0e.0 to 64
 ff:ff:ff:ff:ff:ff, IRQ 9
  product code ffff rev ffff.15 date 15-31-127
Full duplex capable
  Internal config register is ffffffff, transceivers 0xffff.
  1024K word-wide RAM 3:5 Rx:Tx split, autoselect/<invalid transceiver> interface.
  ***WARNING*** No MII transceivers found!
  Enabling bus-master transmits and early receives.
0000:00:0e.0: scatter/gather enabled. h/w checksums enabled

If the patch in 1.1046.589.6 (key:
akpm@osdl.org|ChangeSet|20030801165536|51693) is reversed, the problem
goes away.  But since that would be a drastic step for some buggy
BIOSes, would a patch to add in a disable_wol (and maybe a prink about
it, if no MII transceivers are found?) be an OK fix for this?

OTOH, this looks like bugme # 1394, and if so, it looks like there's a
number of buggy BIOS out there, so maybe it's not so drastic.

-- 
Tom Rini
http://gate.crashing.org/~trini/
