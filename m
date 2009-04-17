From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13129] New: Kernel panic after adding tap
 interface to bridge
Date: Fri, 17 Apr 2009 11:48:00 -0700
Message-ID: <20090417114800.e7fbeb08.akpm@linux-foundation.org>
References: <bug-13129-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Max Krasnyansky <maxk@qualcomm.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59814 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756818AbZDQSvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 14:51:14 -0400
In-Reply-To: <bug-13129-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 17 Apr 2009 13:51:06 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13129

There's some additional info at the bugzillal ink.

>            Summary: Kernel panic after adding tap interface to bridge
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.27.21
>           Platform: All
>         OS/Version: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: aatrof@gmail.com
>         Regression: No
> 
> 
> Created an attachment (id=21029)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=21029)
> serial output after kernel panic
> 
> Box has a 1 active truncated Ethernet link with dozens VLANs. During system
> startup virtual interfaces are created to separate each VLAN data from the
> others'. Several brigdes sit on the top of them, one for each VLAN. Everything
> works fine until I try to add kvm linux guest to whichever VLAN brigde. Then
> kernel freezes in a few seconds.
> 
> Steps to reproduce:
> 
> 1) configure network interfaces accordingly to what has been described above
> (standard RedHat/Fedora config files in /etc/sysconfig/network-scripts
> suffice).
> 2) create TAP device using tunctl
> 3) change the state of the device to up 
> 4) add it to one of the bridges
> 5) run guest machine with one interface paired with previously created TAP
> device
> 
> Steps 2-4 can be handled automatically by qemu-kvm running script like this
> one:
> 
> #!/bin/sh
> # prep_script.sh
> set -x
> 
> switch=br100
> 
> if [ -n "$1" ];then
>         /usr/sbin/tunctl -p -t $1
>         /sbin/ip link set $1 up
>         sleep 0.5s
>         /usr/sbin/brctl addif $switch $1
>         exit 0
> else
>         echo "Error: no interface specified"
>         exit 1
> fi
> 
> Then guest can be fired up using the following command:
> 
> qemu-kvm -m 1024 -net nic,model=e1000 -net tap,script=/path/to/prep_script.sh
> /path/to/disk.img
> 
> Additional info:
> 
> Host: Fedora 10 (see kernel ring buffer output file and kernel config file)
> Guest: CentOS 5.3
> 

