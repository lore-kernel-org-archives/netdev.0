From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 36602] New: Bridge fails to work normally
 without net.ipv4.ip_forward=1
Date: Fri, 3 Jun 2011 12:36:32 -0700
Message-ID: <20110603123632.139f83ca.akpm@linux-foundation.org>
References: <bug-36602-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, igor@novg.net,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57334 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755779Ab1FCThN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 15:37:13 -0400
In-Reply-To: <bug-36602-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 3 Jun 2011 19:21:20 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=36602
> 
>            Summary: Bridge fails to work normally without
>                     net.ipv4.ip_forward=1
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.38.7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: igor@novg.net
>         Regression: No
> 
> 
> Yes, this seems strange, but it's seems to be true.
> 
> My network scheme is quite simple:
> 
> (host1) <--- 10gbe ---> (bridge host) <--- 10gbe ---> (host2)
> 
> host1 & host2 are actually VMWare ESXi hypervisors, but that's irrelevant in
> this case i think.
> 
> Network adapters are Intel's 82599 10 gig cards on all hosts.
> 
> At the bridge, on each interface i've created a vlan, and then bridged them:
> # vconfig add eth0 102
> # vconfig add eth1 102
> # brctl addbr br0
> # brctl addif br0 eth0.102
> # brctl addif br0 eth1.102
> # ip link set br0 mtu 9000 up
> ...etc...
> 
> At this point, the bridge seems to be working, i can ping between host1 &
> host2, even with jumbo frames without fragmentation.
> 
> BUT when i am trying to use iperf & friends to measure raw tcp speed between
> hosts 1/2, i'm getting something weird like 7-10 MEGABITS per second, or even
> an iperf hang until ctrl+c.
> 
> If i attach an ip address to the bridge, and measure between hosts and the
> bridge, it works flawlessly, rendering 9.8Gbit/s in both directions.
> 
> While trying to find a solution, when i ran out of options, i've set
> net.ipv4.ip_forward to 1, and, SURPRISE, the bridge started to work like a
> charm, at almost 10gig speed.
> 
> What makes it stranger, is that in my kernel, i've turned off all routing code,
> iptables and other stuff, as this host serves primarily as iSCSI target.
> 
> I have little knowledge in kernel's deep internals, but i always thought that
> bridging & routing are on different levels of operation and couldn't affect
> each other (ebtables is an exception, but i don't have it :) ).
> 
> Maybe i'm interpreting the results wrong, but i've ruled out everything else.
> 
> Currently, i can't use this setup as a test ground, i'll try to replicate the
> scheme in a virtual environment to see if other kernels are affected as well.
> 
> Glad to hear any ideas on this.
> 

