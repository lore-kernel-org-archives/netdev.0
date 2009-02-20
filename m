From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12743] New: Oops when renaming interfaces
 added to a bridge
Date: Fri, 20 Feb 2009 09:45:19 -0800
Message-ID: <20090220094519.d8ad0496.akpm@linux-foundation.org>
References: <bug-12743-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	enrico.scholz@informatik.tu-chemnitz.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50988 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752870AbZBTRpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 12:45:32 -0500
In-Reply-To: <bug-12743-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 20 Feb 2009 04:01:27 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12743
> 
>            Summary: Oops when renaming interfaces added to a bridge
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.27.18
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: enrico.scholz@informatik.tu-chemnitz.de
> 
> 
> Distribution: custom 
> Hardware Environment: ARM PXA320
> [reproduced on Fedora 10 with 2.6.27.15-170.2.24.fc10.x86_64 too]
> 
> Problem Description:
> 
> When renaming an interface which was added to a bridge, its name won't
> be changed in the bridge setup.  Adding another interface which was
> created later with the original name,  kernel oopses
> 
> A 'find /sys -name dummy*' between step 4 and 5 reports
> 
> /sys/devices/virtual/net/br0/brif/dummy0
> /sys/devices/virtual/net/dummy100
> /sys/bus/i2c/drivers/dummy
> /sys/class/net/dummy100
> 
> 
> Although it is only a WARNING, system goes havoc because whole
> networking stack seems to be unusable then.
> 
> 
> 
> Steps to reproduce:
> 
> 1. brctl addbr br0
> 
> 2. modprobe -o d0 dummy
> 3. brctl addif br0 dummy0
> 
> 4. ifrename -i dummy0 -n dummy100
> 
> 5. modprobe -o d1 dummy
> 6. brctl addif br0 dummy0
> 
> 
> device dummy0 entered promiscuous mode
> ------------[ cut here ]------------
> WARNING: at fs/sysfs/dir.c:463 sysfs_add_one+0x34/0x48()
> ....
> 
> 

