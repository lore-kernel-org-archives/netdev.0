From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12339] New: ne2000 doesn't set udev DRIVER
 attribute
Date: Mon, 5 Jan 2009 14:54:27 -0800
Message-ID: <20090105145427.7d34fc2e.akpm@linux-foundation.org>
References: <bug-12339-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Christopher Head <chead@telus.net>,
	Daniel Drake <dsd@gentoo.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46684 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750889AbZAEWzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 17:55:10 -0500
In-Reply-To: <bug-12339-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 31 Dec 2008 16:44:31 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12339
> 
>            Summary: ne2000 doesn't set udev DRIVER attribute
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.28
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: chead@telus.net
> 
> 
> The ne2000 driver does not set the DRIVER attribute in udev. This causes
> persistent network device naming to ignore the device, thinking it to be a
> virtual device of some sort that ought not to be persistently named.
> 
> Relevant output:
> # udevadm info -a -p /sys/class/net/eth0
> 
> Udevinfo starts with the device specified by the devpath and then
> walks up the chain of parent devices. It prints for every device
> found, all possible attributes in the udev rules key format.
> A rule to match, can be composed by the attributes of the device
> and the attributes from one single parent device.
> 
>   looking at device '/devices/virtual/net/eth0':
>     KERNEL=="eth0"
>     SUBSYSTEM=="net"
>     DRIVER==""
>     ATTR{addr_len}=="6"
>     ATTR{iflink}=="2"
>     ATTR{ifindex}=="2"
>     ATTR{features}=="0x0"
>     ATTR{type}=="1"
>     ATTR{link_mode}=="0"
>     ATTR{address}=="00:80:c8:2c:71:a2"
>     ATTR{broadcast}=="ff:ff:ff:ff:ff:ff"
>     ATTR{carrier}=="1"
>     ATTR{dormant}=="0"
>     ATTR{operstate}=="unknown"
>     ATTR{mtu}=="1500"
>     ATTR{flags}=="0x1003"
>     ATTR{tx_queue_len}=="1000"
> 
>   looking at parent device '/devices/virtual/net':
>     KERNELS=="net"
>     SUBSYSTEMS==""
>     DRIVERS==""
> 
>   looking at parent device '/devices/virtual':
>     KERNELS=="virtual"
>     SUBSYSTEMS==""
>     DRIVERS==""
> 
> 
> Downstream <http://bugs.gentoo.org/show_bug.cgi?id=252449>, Daniel Drake
> suggests that maybe "this is because the driver does not call
> SET_NETDEV_DEV()".
> 


