From: Nick Bowler <nbowler@elliptictech.com>
Subject: Sudden kernel panic with skge in 3.3-rc2
Date: Thu, 2 Feb 2012 14:21:15 -0500
Message-ID: <20120202192115.GA8480@elliptictech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I just saw this panic on 3.3-rc2 with skge.  I don't know whether it's
reproducible yet -- the machine crashed while I was not actively using
it.  We've had this type of card for a few years and I've never seen this
before so it may be a regression, but admittedly we don't use them all
that often.

At the time of the crash, the network interface in question was up, but
not configured with any addresses; mtu configured to (the default) 1500
bytes.  It was used for packet capture (tcpdump) shortly beforehand,
although this was not running at the time of the crash.  It's a PCI
gigabit ethernet card:

  03:01.0 Ethernet controller: D-Link System Inc DGE-530T Gigabit Ethernet Adapter (rev 11) (rev 11)

In case it matters, the primary network interface of the system is an
onboard device using the sky2 driver:

  02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8057 PCI-E Gigabit Ethernet Controller (rev 10Ethernet controller: Marvell Technology Group Ltd. 88E8057 PCI-E Gigabit Ethernet Controller (rev 10)

I took a photo of the screen, but unfortuately the top few lines are
lost forever.  Posted at imgur because it seems a bit big for the
mailing lists: <http://i.imgur.com/xklGU.jpg>. Apologies for the
terrible quality; the best camera I could find around was in someone's
mobile phone.  I'll see about configuring a serial console in case it
crashes again.

For convenience (hopefully), here's the call trace retyped in plain text
(addresses elided, see photo for them).  The full code line is
reproduced by hand because it's almost unreadable in the photo (and
truncated to boot).

  Call Trace:
   <IRQ>
   [...] net_rx_action+0xaa/0x1c0
   [...] __do_softirq+0x7e/0x125
   [...] ? _raw_spin_unlock+0x26/0x31
   [...] call_softirq+0x1c/0x30
   [...] do_softirq+0x33/0x68
   [...] irq_exit+0x3f/0xb9
   [...] do_IRQ+0x97/0xae
   [...] common_interrupt+0x6b/0x6b
   <EOI>
   [...] ? hrtimer_start+0x13/0x15
   [...] ? mwait_idle+0x6e/0x80
   [...] ? mwait_idle+0x61/0x80
   [...] cpu_idle+0x61/0xbd
   [...] rest_init+0x8d/0x91
   [...] start_kernel+0x338/0x343
   [...] x86_64_start_reservations+0xb8/0xbd
   [...] x86_64_start_kernel+0xed/0xf4
  Code: 48 8b 40 30 48 85 c0 74 0a b9 02 00 00 00 4c 89 fa ff d0 49 8b 86 d0 00 00 00 49 8b 4d b4 48 89 c7 48 8b b2 d0 00 00 00 <f3> a4 31 ff 48 8b 03 49 8b 75 18 48 8b 40 08 48 85 c0 74 13 48
  RIP  [...] skge_poll+0x367/0x5cd [skge]

Let me know if you need any more info,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
