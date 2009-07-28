From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13830] New: 8139too - packets dropped/lost by
 ethernet stack
Date: Tue, 28 Jul 2009 15:26:38 -0700
Message-ID: <20090728152638.eea18607.akpm@linux-foundation.org>
References: <bug-13830-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, aldursys@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56179 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754521AbZG1W1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 18:27:09 -0400
In-Reply-To: <bug-13830-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 26 Jul 2009 10:32:52 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13830
> 
>            Summary: 8139too - packets dropped/lost by ethernet stack
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.28, 2.6.31
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: aldursys@gmail.com
>         Regression: No
> 
> 
> I'm losing receive packets with the 8139too REALTEK driver when I place the
> driver under load.
> 
> Details:
> 
> distribution: Ubuntu Jaunty 9.04, Ubuntu Karmic Alpha-3.
> 
> eth0      Link encap:Ethernet  HWaddr 00:1b:38:08:7f:d3  
>           inet addr:192.168.2.3  Bcast:192.168.2.255  Mask:255.255.255.0
>           inet6 addr: fe80::21b:38ff:fe08:7fd3/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:9164 errors:94 dropped:94 overruns:94 frame:0
>           TX packets:7497 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:12058463 (12.0 MB)  TX bytes:792762 (792.7 KB)
>           Interrupt:21 Base address:0x2000 
> 
> Dmesg details
> 
> [    4.357046] 8139cp: 10/100 PCI Ethernet driver v1.3 (Mar 22, 2004)
> [    4.357092] 8139cp 0000:05:01.0: This (id 10ec:8139 rev 10) is not an 8139C+ 
> compatible chip, use 8139too
> [    4.359452] 8139too Fast Ethernet driver 0.9.28
> [    4.359513] 8139too 0000:05:01.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
> [    4.359527] 8139too 0000:05:01.0: setting latency timer to 64
> [    4.360886] eth0: RealTek RTL8139 at 0x2000, 00:1b:38:08:7f:d3, IRQ 21
> [    4.360889] eth0:  Identified 8139 chip type 'RTL-8100B/8139D'
> 
> 
> The problem appears to goes away if I enable just the debug message at the end
> of the function in the interrupt handler (rtl8139_interrupt) which sort of
> suggests that something is coming into the driver faster than it can handle or
> it is missing a state somewhere. 
> 
> (I get much better throughput with the debug message on than without it).
> 
> Also none of the error counters appear to be incremented by the driver itself -
> suggesting again that the higher level is expecting something the driver isn't
> providing.
> 
> Bug 10682 may be related (http://bugzilla.kernel.org/show_bug.cgi?id=10682) but
> isn't exactly the same.
> 
> More details at https://bugs.launchpad.net/ubuntu/+source/linux/+bug/401891

