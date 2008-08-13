From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
 iptables nat routing
Date: Tue, 12 Aug 2008 22:12:04 -0700
Message-ID: <20080812221204.46afb4a6.akpm@linux-foundation.org>
References: <bug-11316-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, alex.williamson@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38625 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751362AbYHMFMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 01:12:39 -0400
In-Reply-To: <bug-11316-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 12 Aug 2008 22:04:41 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11316
> 
>            Summary: severe performance regression for iptables nat routing
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.27-rc3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Netfilter/Iptables
>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>         ReportedBy: alex.williamson@hp.com
> 
> 
> Latest working kernel version: 2.6.26.2
> Earliest failing kernel version: 2.6.27-rc2 (maybe earlier)
> Distribution: Ubuntu
> Hardware Environment: x86_64
> Software Environment: 32bit userspace/64bit kernel
> Problem Description: When using iptables to intercept addr:port and reroute
> through an ssh tunnel, I see a huge performance hit on the 2.6.27-rc series
> relative to 2.6.26 (34KB/s vs 1+MB/s).
> 
> Steps to reproduce:
> 
> Setup and ssh tunnel to one of the kernel.org servers using a system on your
> local network:
> 
> ssh -L 8888:204.152.191.37:80 <local system>
> 
> Leave the ssh session running.  In a new terminal (on your local system),
> verify performance of direct access versus the tunnel:
> 
> wget -O /dev/null
> http://204.152.191.37/pub/linux/kernel/v2.6/linux-2.6.26.2.tar.bz2
> wget -O /dev/null
> http://127.0.0.1:8888/pub/linux/kernel/v2.6/linux-2.6.26.2.tar.bz2
> 
> These should be roughly the same.  Now setup iptables so that when you try to
> access 204.152.191.37:80 you'll automatically be redirected to the ssh tunnel:
> 
> sudo iptables -t nat -N bug
> sudo iptables -t nat -I OUTPUT 1 -j bug
> sudo iptables -t nat -A bug -d 204.152.191.37 -p tcp --dport 80 -j DNAT
> --to-destination 127.0.0.1:8888
> 
> Repeat the performance test:
> 
> wget -O /dev/null
> http://204.152.191.37/pub/linux/kernel/v2.6/linux-2.6.26.2.tar.bz2
> wget -O /dev/null
> http://127.0.0.1:8888/pub/linux/kernel/v2.6/linux-2.6.26.2.tar.bz2
> 
> On 2.6.27-rc2+ My rate quickly drops down to ~34KB/s using the iptables nat'd
> wget (204.152.191.37) while the ssh tunnel still runs 1+MB/s.  On 2.6.26 I get
> similar performance for both paths.
> 

