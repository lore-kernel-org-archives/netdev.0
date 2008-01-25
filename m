From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9810] New: Bridge doesn't work with e1000e
 driver
Date: Fri, 25 Jan 2008 01:33:14 -0800
Message-ID: <20080125013314.ec585b1b.akpm@linux-foundation.org>
References: <bug-9810-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>, cijoml@volny.cz,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58674 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753633AbYAYJdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 04:33:44 -0500
In-Reply-To: <bug-9810-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, 25 Jan 2008 01:13:19 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=9810
> 
>            Summary: Bridge doesn't work with e1000e driver
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-rc8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: cijoml@volny.cz
> 
> 
> Latest working kernel version: unknown
> Earliest failing kernel version: unknown
> Distribution: Debian stable
> Hardware Environment: Dell Optiplex 755
> Software Environment: Debian stable, vanilla 2.6.24-rc8
> Problem Description:
> 
> Bridge doesn't work with e1000e driver
> 
> Steps to reproduce:
> 
> optiplex:/home/cijoml# brctl addbr br0
> optiplex:/home/cijoml# brctl addif br0 eth0
> optiplex:/home/cijoml# brctl show
> bridge name     bridge id               STP enabled     interfaces
> br0             8000.001e4f93dd74       no              eth0
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> optiplex:/home/cijoml# killall dhclient
> dhclient: no process killed
> optiplex:/home/cijoml# dhclient br0
> Internet Systems Consortium DHCP Client V3.0.4
> Copyright 2004-2006 Internet Systems Consortium.
> All rights reserved.
> For info, please visit http://www.isc.org/sw/dhcp/
> 
> Listening on LPF/br0/00:1e:4f:93:dd:74
> Sending on   LPF/br0/00:1e:4f:93:dd:74
> Sending on   Socket/fallback
> DHCPREQUEST on br0 to 255.255.255.255 port 67
> DHCPREQUEST on br0 to 255.255.255.255 port 67
> DHCPREQUEST on br0 to 255.255.255.255 port 67
> DHCPDISCOVER on br0 to 255.255.255.255 port 67 interval 6
> DHCPDISCOVER on br0 to 255.255.255.255 port 67 interval 8
> DHCPDISCOVER on br0 to 255.255.255.255 port 67 interval 12
> DHCPDISCOVER on br0 to 255.255.255.255 port 67 interval 18
> DHCPDISCOVER on br0 to 255.255.255.255 port 67 interval 17
> No DHCPOFFERS received.
> Trying recorded lease 10.136.212.12
> PING 10.136.212.1 (10.136.212.1) 56(84) bytes of data.
> 
> --- 10.136.212.1 ping statistics ---
> 1 packets transmitted, 0 received, +1 errors, 100% packet loss, time 0ms
> 
> No working leases in persistent database - sleeping.
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> optiplex:/home/cijoml# killall dhclient
> optiplex:/home/cijoml# ifconfig br0 down
> optiplex:/home/cijoml# brctl delbr br0
> optiplex:/home/cijoml# dhclient eth0
> Internet Systems Consortium DHCP Client V3.0.4
> Copyright 2004-2006 Internet Systems Consortium.
> All rights reserved.
> For info, please visit http://www.isc.org/sw/dhcp/
> 
> Listening on LPF/eth0/00:1e:4f:93:dd:74
> Sending on   LPF/eth0/00:1e:4f:93:dd:74
> Sending on   Socket/fallback
> DHCPREQUEST on eth0 to 255.255.255.255 port 67
> DHCPREQUEST on eth0 to 255.255.255.255 port 67
> DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 6
> ip length 339 disagrees with bytes received 343.
> accepting packet with data after udp payload.
> DHCPOFFER from 10.136.212.2
> DHCPREQUEST on eth0 to 255.255.255.255 port 67
> ip length 339 disagrees with bytes received 343.
> accepting packet with data after udp payload.
> ip length 339 disagrees with bytes received 343.
> accepting packet with data after udp payload.
> DHCPACK from 10.136.212.2
> bound to 10.136.212.15 -- renewal in 1149646 seconds.
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> 
> 
