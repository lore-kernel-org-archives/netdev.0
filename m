From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12282] New: Network data corruption on eee
 1000
Date: Tue, 23 Dec 2008 23:20:35 -0800
Message-ID: <20081223232035.5a5caea9.akpm@linux-foundation.org>
References: <bug-12282-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, walken@zoy.org,
	"J. K. Cliburn" <jcliburn@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44361 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750705AbYLXHUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 02:20:46 -0500
In-Reply-To: <bug-12282-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 23 Dec 2008 21:24:45 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12282
> 
>            Summary: Network data corruption on eee 1000
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.28-rc8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: walken@zoy.org
> 
> 
> Latest working kernel version: unknown
> Earliest failing kernel version: 2.6.28-rc8
> Distribution: debian lenny
> Hardware Environment: eee 1000, no hardware changes except for a 2GB memory
> upgrade.
> Software Environment:
> Problem Description: Intermittent data corruption over wired network
> 
> 
> Running debian lenny on my eee 1000, I've seen occasional scp failures where
> scp would complain about a corrupted MAC when copying files around on my local
> network. Also when compiling things over NFS I occasionally got my source files
> to appear corrupted on the client (while they were still fine on the server)
> and when I tried running things in an nfsroot environment (I know this sounds
> silly for a laptop, but I see it as a good way to try new software without
> having to install it on disk), I got occasional segfaults in various processes.
> Since I've not seen such failures when running with a disk based root, I blame
> them all on the networking subsystem.
> 
> 
> I've been running the following command as a way to try and reproduce the
> problem:
> 
> for x in 0 1 2 3 4 5 6 7 8 9; do for y in 0 1 2 3 4 5 6 7 8 9; do for z in 0 1
> 2 3 4 5 6 7 8 9; do echo $x$y$z; scp server:shared/net_test/data1GB /tmp ||
> sleep 36000; date; done; done; done
> 000
> data1GB                                       100% 1005MB   5.2MB/s   03:15    
> Tue Dec 23 20:17:36 PST 2008
> 001
> data1GB                                       100% 1005MB   5.2MB/s   03:12    
> Tue Dec 23 20:20:49 PST 2008
> 002
> data1GB                                       100% 1005MB   5.2MB/s   03:13    
> Tue Dec 23 20:24:03 PST 2008
> 003
> data1GB                                       100% 1005MB   6.4MB/s   02:38    
> Tue Dec 23 20:26:42 PST 2008
> 004
> data1GB                                        98%  994MB   5.4MB/s   00:02
> ETADisconnecting: Corrupted MAC on input.
> lost connection
> 
> The failures don't always happen at the same place, and they might be slightly
> more likely soon after boot, but I'm not sure about that.
> 
> Even after scp detected some data corruption, ifconfig does not report any
> errors:
> 
> eth0      Link encap:Ethernet  HWaddr 00:22:15:85:7c:94  
>           inet addr:10.3.0.1  Bcast:10.255.255.255  Mask:255.0.0.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:3683950 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:1432256 errors:0 dropped:0 overruns:0 carrier:2
>           collisions:0 txqueuelen:1000 
>           RX bytes:1246310892 (1.1 GiB)  TX bytes:101092933 (96.4 MiB)
>           Interrupt:59 
> 
> (Note the RX bytes value is also wrong since I transferred almost 5GB above,
> I believe this is because the value wraps around after 4GB ? Also,
> /proc/interrupts reports >3 million interrupts (PCI-MSI-edge) on eth0)
> 
> I'm tempted to blame either the hardware or the newish atl1e network driver,
> but have no hard proof either way at this point.
> 

