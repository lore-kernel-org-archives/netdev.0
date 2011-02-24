From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 29712] New: Bonding Driver(version : 3.5.0) -
 Problem with ARP monitoring in active backup mode
Date: Thu, 24 Feb 2011 14:51:29 -0800
Message-ID: <20110224145129.f366b59e.akpm@linux-foundation.org>
References: <bug-29712-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: harsha.r02@mphasis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40669 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756118Ab1BXWwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 17:52:15 -0500
In-Reply-To: <bug-29712-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 23 Feb 2011 10:41:34 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=29712
> 
>            Summary: Bonding Driver(version : 3.5.0) - Problem with ARP
>                     monitoring in active backup mode
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.32

That's a paleolithic kernel you have there.  This problem might have
been fixed already.  Can you test a more recent kernel?


>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: harsha.r02@mphasis.com
>         Regression: No
> 
> 
> We are facing an issue with arp_monitoring in active_backup mode when
> two network interfaces of two systems are connected back to back (point
> to point connected without switch connection) and bond is created on
> either systems with point-to-point connected interfaces as slaves.
> 
> Steps to reproduce :
> 
> 1. Initially the bond was created with two interfaces eth2 and eth3, having
> eth2 as primary
> 
>     # modprobe bonding primary=eth2 mode=1 arp_interval=500
>     arp_ip_target=192.168.4.61
> 
>     # ifconfig bond0 192.168.2.63 netmask 255.255.255.0
> 
>     # ifenslave bond0 eth2 eth3
> 
>     # ifconfig bond0 up
> 
>     # cat /proc/net/bonding/bond0
> 
>     Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
> 
>     Bonding Mode: fault-tolerance (active-backup)
> 
>     Primary Slave: eth2
>     Currently Active Slave: eth2
>     MII Status: up
>     MII Polling Interval (ms): 0
>     Up Delay (ms): 0
>     Down Delay (ms): 0
>     ARP Polling Interval (ms): 500
>     ARP IP target/s (n.n.n.n form): 192.168.4.61
> 
>     Slave Interface: eth2
>     MII Status: up
>     Link Failure Count: 1
>     Permanent HW addr: 00:26:55:27:88:52
> 
>     Slave Interface: eth3
>     MII Status: down
>     Link Failure Count: 1
>     Permanent HW addr: 00:26:55:27:88:54
> 
> 2. The primary interface was made down, and fail over happened
> 
>     # ifconfig down
> 
>     # cat /proc/net/bonding/bond0
> 
>     Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
> 
>     Bonding Mode: fault-tolerance (active-backup)
>     Primary Slave: eth2
>     Currently Active Slave: eth3 <-- As expected -->
>     MII Status: up
>     MII Polling Interval (ms): 0
>     Up Delay (ms): 0
>     Down Delay (ms): 0
>     ARP Polling Interval (ms): 500
>     ARP IP target/s (n.n.n.n form): 192.168.4.61
> 
>     Slave Interface: eth2
>     MII Status: down
>     Link Failure Count: 2
>     Permanent HW addr: 00:26:55:27:88:52
> 
>     Slave Interface: eth3
>     MII Status: up
>     Link Failure Count: 1
>     Permanent HW addr: 00:26:55:27:88:54
> 
> 3. The primary interface was brought up again and we did not see failover
> happening back to primary
> 
>     ned1g6:~# ifconfig eth2 up
> 
>     ned1g6:~# cat /proc/net/bonding/bond0
> 
>     Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
> 
>     Bonding Mode: fault-tolerance (active-backup)
>     Primary Slave: eth2
>     Currently Active Slave: eth3 <-- Ideally this should have been eth2 -->
>     MII Status: up
>     MII Polling Interval (ms): 0
>     Up Delay (ms): 0
>     Down Delay (ms): 0
>     ARP Polling Interval (ms): 500
>     ARP IP target/s (n.n.n.n form): 192.168.4.61
> 
>     Slave Interface: eth2
>     MII Status: down
>     Link Failure Count: 2
>     Permanent HW addr: 00:26:55:27:88:52
> 
>     Slave Interface: eth3
>     MII Status: up
>     Link Failure Count: 1
>     Permanent HW addr: 00:26:55:27:88:54
> 
> The problem is that when the primary_slave comes up from the down state
> it won't get selected as the currently active slave for the bond.
> 
> Best Regards,
> Harsha

