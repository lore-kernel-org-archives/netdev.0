From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12570] New: Bonding does not
	work over e1000e.
Date: Thu, 29 Jan 2009 09:52:35 -0800
Message-ID: <20090129095235.37aba564.akpm@linux-foundation.org>
References: <bug-12570-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: khorenko@parallels.com, bugme-daemon@bugzilla.kernel.org
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	bonding-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <bug-12570-10286@http.bugzilla.kernel.org/>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 29 Jan 2009 03:12:01 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12570
> 
>            Summary: Bonding does not work over e1000e.
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.29-rc1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: khorenko@parallels.com
> 
> 
> Checked (failing) kernel: 2.6.29-rc1
> Latest working kernel version: unknown
> Earliest failing kernel version: not checked but probably any. RHEL5 kernels
> are also affected.
> 
> Distribution: Enterprise Linux Enterprise Linux Server release 5.1 (Carthage)
> 
> Hardware Environment:
> lspci:
> 15:00.0 Ethernet controller: Intel Corporation 82571EB Quad Port Gigabit
> Mezzanine Adapter (rev 06)
> 15:00.1 Ethernet controller: Intel Corporation 82571EB Quad Port Gigabit
> Mezzanine Adapter (rev 06)
> 
> 15:00.0 0200: 8086:10da (rev 06)
>         Subsystem: 103c:1717
>         Flags: bus master, fast devsel, latency 0, IRQ 154
>         Memory at fdde0000 (32-bit, non-prefetchable) [size=128K]
>         Memory at fdd00000 (32-bit, non-prefetchable) [size=512K]
>         I/O ports at 6000 [size=32]
>         [virtual] Expansion ROM at d1300000 [disabled] [size=512K]
>         Capabilities: [c8] Power Management version 2
>         Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0
> Enable+
>         Capabilities: [e0] Express Endpoint IRQ 0
>         Capabilities: [100] Advanced Error Reporting
>         Capabilities: [140] Device Serial Number 24-d1-78-ff-ff-78-1b-00
> 
> 15:00.1 0200: 8086:10da (rev 06)
>         Subsystem: 103c:1717
>         Flags: bus master, fast devsel, latency 0, IRQ 162
>         Memory at fdce0000 (32-bit, non-prefetchable) [size=128K]
>         Memory at fdc00000 (32-bit, non-prefetchable) [size=512K]
>         I/O ports at 6020 [size=32]
>         [virtual] Expansion ROM at d1380000 [disabled] [size=512K]
>         Capabilities: [c8] Power Management version 2
>         Capabilities: [d0] Message Signalled Interrupts: 64bit+ Queue=0/0
> Enable+
>         Capabilities: [e0] Express Endpoint IRQ 0
>         Capabilities: [100] Advanced Error Reporting
>         Capabilities: [140] Device Serial Number 24-d1-78-ff-ff-78-1b-00
> 
> Problem Description: Bonding does not work over NICs supported by e1000e: if
> you brake/restore physical links of bonding slaves one by one - network won't
> work anymore.
> 
> Steps to reproduce:
> 2 NICs supported by e1000e put into bond device (Bonding Mode: fault-tolerance
> (active-backup)).
> * ping to the outside node is ok
> * physically brake the link of active bond slave (1)
> * bond detects the failure, makes another slave (2) active.
> * ping works fine
> * restore the connection of (1)
> * ping works fine
> * brake the link of (2)
> * bond detects it, reports that it makes active (1), but
> * ping _does not_ work anymore
> 
> Logs:
> /var/log/messages:
> Jan 27 11:53:29 host kernel: 0000:15:00.0: eth2: Link is Down
> Jan 27 11:53:29 host kernel: bonding: bond1: link status definitely down for
> interface eth2, disabling it
> Jan 27 11:53:29 host kernel: bonding: bond1: making interface eth3 the new
> active one.
> Jan 27 11:56:37 host kernel: 0000:15:00.0: eth2: Link is Up 1000 Mbps Full
> Duplex, Flow Control: RX/TX
> Jan 27 11:56:37 host kernel: bonding: bond1: link status definitely up for
> interface eth2.
> Jan 27 11:57:39 host kernel: 0000:15:00.1: eth3: Link is Down
> Jan 27 11:57:39 host kernel: bonding: bond1: link status definitely down for
> interface eth3, disabling it
> Jan 27 11:57:39 host kernel: bonding: bond1: making interface eth2 the new
> active one.
> 
> What was done + dumps of /proc/net/bonding/bond1:
> ## 11:52:42
> ##cat /proc/net/bonding/bond1
> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
> 
> Bonding Mode: fault-tolerance (active-backup)
> Primary Slave: None
> Currently Active Slave: eth2
> MII Status: up
> MII Polling Interval (ms): 100
> Up Delay (ms): 0
> Down Delay (ms): 0
> 
> Slave Interface: eth2
> MII Status: up
> Link Failure Count: 0
> Permanent HW addr: 00:17:a4:77:00:1c
> 
> Slave Interface: eth3
> MII Status: up
> Link Failure Count: 0
> Permanent HW addr: 00:17:a4:77:00:1e
> 
> ## 11:53:05 shutdown eth2 uplink on the virtual connect bay5
> ##cat /proc/net/bonding/bond1
> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
> 
> Bonding Mode: fault-tolerance (active-backup)
> Primary Slave: None
> Currently Active Slave: eth3
> MII Status: up
> MII Polling Interval (ms): 100
> Up Delay (ms): 0
> Down Delay (ms): 0
> 
> Slave Interface: eth2
> MII Status: down
> Link Failure Count: 1
> Permanent HW addr: 00:17:a4:77:00:1c
> 
> Slave Interface: eth3
> MII Status: up
> Link Failure Count: 0
> Permanent HW addr: 00:17:a4:77:00:1e
> 
> ## 11:56:01 turn on eth2 uplink on the virtual connect bay5
> ##cat /proc/net/bonding/bond1
> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
> 
> Bonding Mode: fault-tolerance (active-backup)
> Primary Slave: None
> Currently Active Slave: eth3
> MII Status: up
> MII Polling Interval (ms): 100
> Up Delay (ms): 0
> Down Delay (ms): 0
> 
> Slave Interface: eth2
> MII Status: down
> Link Failure Count: 1
> Permanent HW addr: 00:17:a4:77:00:1c
> 
> Slave Interface: eth3
> MII Status: up
> Link Failure Count: 0
> Permanent HW addr: 00:17:a4:77:00:1e
> 
> ## 11:57:22 turn off eth3 uplink on the virtual connect bay5
> ##cat /proc/net/bonding/bond1
> Ethernet Channel Bonding Driver: v3.3.0 (June 10, 2008)
> 
> Bonding Mode: fault-tolerance (active-backup)
> Primary Slave: None
> Currently Active Slave: eth2
> MII Status: up
> MII Polling Interval (ms): 100
> Up Delay (ms): 0
> Down Delay (ms): 0
> 
> Slave Interface: eth2
> MII Status: up
> Link Failure Count: 1
> Permanent HW addr: 00:17:a4:77:00:1c
> 
> Slave Interface: eth3
> MII Status: down
> Link Failure Count: 1
> Permanent HW addr: 00:17:a4:77:00:1e
> 


------------------------------------------------------------------------------
This SF.net email is sponsored by:
SourcForge Community
SourceForge wants to tell your story.
http://p.sf.net/sfu/sf-spreadtheword
