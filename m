From: "Graham, David" <david.graham@intel.com>
Subject: RE: [E1000-devel] [Bugme-new] [Bug 12570] New: Bonding does not
	work over e1000e.
Date: Tue, 17 Feb 2009 11:00:56 -0800
Message-ID: <13830B75AD5A2F42848F92269B11996F3C5C645A@orsmsx509.amr.corp.intel.com>
References: <8DD2590731AB5D4C9DBF71A877482A900DCA8695@orsmsx509.amr.corp.intel.com>
 <EA929A9653AAE14F841771FB1DE5A1365F60321240@rrsmsx501.amr.corp.intel.com>
 <F169D4F5E1F1974DBFAFABF47F60C10A1C2C9480@orsmsx507.amr.corp.intel.com>
 <EA929A9653AAE14F841771FB1DE5A1365F60321411@rrsmsx501.amr.corp.intel.com>
 <13830B75AD5A2F42848F92269B11996F3A0F5952@orsmsx509.amr.corp.intel.com>
 <498C0E8C.9050309@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"devel@lists.sourceforge.net" <devel@lists.sourceforge.net>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Konstantin Khorenko <khorenko@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5355 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422AbZBQTBK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 14:01:10 -0500
In-Reply-To: <498C0E8C.9050309@parallels.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Konstantin,
To get closer to your environment, I reconfigured my network, and same kernel & built-in driver that you used, but channel failover still works in my tests. Because this is without the recent serdes link patches that I referred to earlier, that means I don't expect them to be significant to the problem.

But there are some very significant differences in our setups, and I want to align my configuration closer to yours.

1) I am using a different Mezz card, with different EEPROM settings (and so features). Could you please send me "ethtool ethx" and "ethtool -e ethx" settings for the problem interfaces ? I may even spot something incorrect in the programming, but if not, I can probably use all or some of your content to make my card behave more like yours.

2) We have different link parters , and disable link in a different way.
I tried to remove the switch modules as you did, but in my bladeserver system, couldn't. There must be some administrative command to allow the latch to unlock, but I am not familiar with it. I'll keep looking. Do you have the same (failing) result if you take the link partners down administratively from the switch console ?

3) I am testing in a different chassis/backplane
Let's address the simpler differences first, but if we go another round or two without being able to figure this out, and you are prepared to send us one of the systems with the problem for definite root cause analysis, you can contact me off-line from this bz and we'll work the detail.

Dave

FYI: here's more info & log that show's how the failover works OK on my system.

      2.6.29-rc1 blade in bladeserver
      Ping from console 
         |         
      +--------+
      |  bond0 |  static address
      ++------++
       |      |
   +---+--+  ++-----+
   | eth2 |  | eth3 |
   +---+--+  ++-----+
       |      |        Serdes Backplane
       |      |
   +---+--+  ++-----+
   | 5/4  |  | 6/4  | Bladeserver wwitch module/port
   +---+--+  ++-----+
       |      |                     
    +--+------+----+
    |  1GB switch  |  External to bladeserver
    +-----+--------+
          |
    +-----+-------+   
    | ping target |
    +-------------+

Linux localhost.localdomain 2.6.29-rc1 #3 SMP Fri Feb 13 21:31:17 EST 2009
x86_64 x86_64 x86_64 GNU/Linux
[root@localhost ~]# ethtool -i eth2
driver: e1000e
version: 0.3.3.3-k6
firmware-version: 5.6-2
bus-info: 0000:07:00.0
[root@localhost ~]# 

07:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
Controller (rev 06)
        Subsystem: NEC Corporation Unknown device 834c
        Flags: bus master, fast devsel, latency 0, IRQ 59
        Memory at dee20000 (32-bit, non-prefetchable) [size=128K]
        Memory at dee00000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at 4000 [size=32]
        [virtual] Expansion ROM at 50200000 [disabled] [size=128K]
        Capabilities: [c8] Power Management version 2
        Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0
Enable+
        Capabilities: [e0] Express Endpoint IRQ 0
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Device Serial Number d8-25-62-ff-ff-97-16-00
00: 86 80 60 10 47 05 10 00 06 00 00 02 08 00 80 00
10: 00 00 e2 de 00 00 e0 de 01 40 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 33 10 4c 83
30: 00 00 00 00 c8 00 00 00 00 00 00 00 04 01 00 00

07:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
Controller (rev 06)
        Subsystem: NEC Corporation Unknown device 834c
        Flags: bus master, fast devsel, latency 0, IRQ 60
        Memory at dee60000 (32-bit, non-prefetchable) [size=128K]
        Memory at dee40000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at 4020 [size=32]
        [virtual] Expansion ROM at 50220000 [disabled] [size=128K]
        Capabilities: [c8] Power Management version 2
        Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0
Enable+
        Capabilities: [e0] Express Endpoint IRQ 0
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Device Serial Number d8-25-62-ff-ff-97-16-00
00: 86 80 60 10 47 05 10 00 06 00 00 02 08 00 80 00
10: 00 00 e6 de 00 00 e4 de 21 40 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 33 10 4c 83
30: 00 00 00 00 c8 00 00 00 00 00 00 00 0c 02 00 00

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:16:97:62:25:d8

Slave Interface: eth3
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:16:97:62:25:d9


// Started a ping to 10.0.0.7, all OK, & TX goes out
// physical eth2

// And then I took eth2's link partner out of service from the admin console at the connected switch port 5/4 , [command = oper/port 4/dis]

Feb 17 21:36:15 localhost kernel: e1000e: eth2 NIC Link is Down
Feb 17 21:36:15 localhost kernel: bonding: bond0: link status definitely down
for interface eth2, disabling it
Feb 17 21:36:15 localhost kernel: bonding: bond0: making interface eth3 the
new active one.
(END) 

Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth3
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: down
Link Failure Count: 1
Permanent HW addr: 00:16:97:62:25:d8

Slave Interface: eth3
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:16:97:62:25:d9

// Restored the link from switch 5/4 (eth2)
//
Feb 17 21:38:29 localhost kernel: e1000e: eth2 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 17 21:38:29 localhost kernel: bonding: bond0: link status definitely up
for interface eth2.

Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth3
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:16:97:62:25:d8

Slave Interface: eth3
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:16:97:62:25:d9

// All still OK, with pings TX out of eth3. Now take down the link at eth3,
// switch module 6 port 4

Feb 17 21:41:41 localhost kernel: e1000e: eth3 NIC Link is Down
Feb 17 21:41:41 localhost kernel: bonding: bond0: link status definitely down
for interface eth3, disabling it
Feb 17 21:41:41 localhost kernel: bonding: bond0: making interface eth2 the
new active one.


Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:16:97:62:25:d8

Slave Interface: eth3
MII Status: down
Link Failure Count: 1
Permanent HW addr: 00:16:97:62:25:d9

// Now restore link 3
Feb 17 21:42:56 localhost kernel: e1000e: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 17 21:42:56 localhost kernel: bonding: bond0: link status definitely up
for interface eth3.

Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth2
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:16:97:62:25:d8

Slave Interface: eth3
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:16:97:62:25:d9

// The ping continued in the background throughout.


