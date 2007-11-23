From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9443] New: RFC4193 IPv6 addresses seem not to
 be completly supported : default gateway not set
Date: Fri, 23 Nov 2007 09:15:02 -0800
Message-ID: <20071123091502.34d1e2ec.akpm@linux-foundation.org>
References: <bug-9443-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, guy.widloecher@vinci.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51153 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753452AbXKWRP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 12:15:28 -0500
In-Reply-To: <bug-9443-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Nov 2007 05:42:35 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9443
> 
>            Summary: RFC4193 IPv6 addresses seem not to be completly
>                     supported : default gateway not set
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22-3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: guy.widloecher@vinci.com
> 
> 
> Most recent kernel where this bug did not occur: unknown
> Distribution: DEBIAN SID
> Hardware Environment: tested on COMPAQ Deskpro EN and VMware Workstation
> Software Environment: reproduced in Kernel Version 2.6.22-14 (UBUNTU)
> Problem Description:
> 
> RFC4193 defines fc00::/8 and fd00::/8 IPv6 addresses known as "Local IPv6
> addresses" and stated that "They are not expected to be routable on the global
> Internet" and "They are routable inside of a more limited area such a site".
> RFC4193 addresses are the equivalent of RFC1918 IPv4 addresses for IPv6.
> 
> When using this kind of address as "static" (iface ... static), the default
> gateway is not set (see the result of the command route -6 : ::/0 route is
> missing), so sending such IPv6 packets outside the local LAN is not possible.
> 
> 
> 
> Steps to reproduce:
> 
> debian:~# cat /etc/network/interfaces
> # This file describes the network interfaces available on your system
> # and how to activate them. For more information, see interfaces(5).
> 
> # The loopback network interface
> auto lo
> iface lo inet loopback
> 
> # The primary network interface
> allow-hotplug eth0
> iface eth0 inet dhcp
> iface eth0 inet6 static
>   pre-up modprobe ipv6
>   address fd12:3000:4000:5000::1
>   netmask 64
>   gateway fd12:3000:4000:5000::100
> debian:~#
> 
> debian:~# ifconfig
> eth0      Link encap:Ethernet  HWaddr 00:0C:29:B8:53:3B
>           inet addr:192.168.19.135  Bcast:192.168.19.255 Mask:255.255.255.0
>           inet6 addr: fd12:3000:4000:5000::1/64 Scope:Global
>           inet6 addr: fe80::20c:29ff:feb8:533b/64 Scope:Link
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:262 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:141 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:28702 (28.0 KiB)  TX bytes:20060 (19.5 KiB)
>           Interrupt:17 Base address:0x1080
> 
> lo        Link encap:Local Loopback
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           inet6 addr: ::1/128 Scope:Host
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:8 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:560 (560.0 b)  TX bytes:560 (560.0 b)
> 
> debian:~#
> 
> debian:~# route -6
> Kernel IPv6 routing table
> Destination                                 Next Hop     Flags Metric Ref   
> Use Iface
> ::1/128                                     ::     U     0      4  1 lo
> fd12:3000:4000:5000::1/128                  ::     U     0      0  1 lo
> fd12:3000:4000:5000::/64                    ::     U     256    0  0 eth0
> fe80::20c:29ff:feb8:533b/128                ::     U     0      0  1 lo
> fe80::/64                                   ::     U     256    0  0 eth0
> ff00::/8                                    ::     U     256    0  0 eth0
> debian:~#
> 
> And adding the default route manually gives an error :
> 
> debian:~# route -A inet6 add ::/0 gw fd12:3000:4000:5000::100 eth0
> SIOCADDRT: Invalid argument
> debian:~#
> 
