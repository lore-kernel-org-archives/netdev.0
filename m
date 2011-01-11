From: Chris Rankin <rankincj@yahoo.com>
Subject: RE: [E1000-devel] [e100] Page allocation failure warning(?) in 2.6.36.3
Date: Tue, 11 Jan 2011 12:59:24 -0800 (PST)
Message-ID: <314995.84049.qm@web121708.mail.ne1.yahoo.com>
References: <F675EE07F28A0A4E933E5F9DD28672FB01197E098F@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Tushar NDave <tushar.n.dave@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web121708.mail.ne1.yahoo.com ([98.138.90.129]:28964 "HELO
	web121708.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754502Ab1AKU7Z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jan 2011 15:59:25 -0500
In-Reply-To: <F675EE07F28A0A4E933E5F9DD28672FB01197E098F@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tushar,

As promised:

$ /sbin/ifconfig -a
br0       Link encap:Ethernet  HWaddr 00:03:47:3b:29:5c  
          inet addr:192.168.0.1  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::203:47ff:fe3b:295c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:372485 errors:0 dropped:0 overruns:0 frame:0
          TX packets:383917 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:37566127 (35.8 MiB)  TX bytes:225458273 (215.0 MiB)

eth0      Link encap:Ethernet  HWaddr 00:90:27:76:d0:ec  
          inet addr:10.0.43.2  Bcast:10.0.43.255  Mask:255.255.255.0
          inet6 addr: fe80::290:27ff:fe76:d0ec/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:432016 errors:0 dropped:0 overruns:0 frame:0
          TX packets:377602 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:229629017 (218.9 MiB)  TX bytes:41958103 (40.0 MiB)

eth1      Link encap:Ethernet  HWaddr 00:03:47:3b:29:5c  
          inet6 addr: fe80::203:47ff:fe3b:295c/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:364683 errors:0 dropped:0 overruns:0 frame:0
          TX packets:369235 errors:1 dropped:0 overruns:0 carrier:1
          collisions:0 txqueuelen:1000 
          RX bytes:42445811 (40.4 MiB)  TX bytes:203414933 (193.9 MiB)

eth2      Link encap:Ethernet  HWaddr 00:03:47:3b:29:5d  
          inet6 addr: fe80::203:47ff:fe3b:295d/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:9059 errors:1 dropped:0 overruns:0 frame:1
          TX packets:15437 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:691449 (675.2 KiB)  TX bytes:22232699 (21.2 MiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:797 errors:0 dropped:0 overruns:0 frame:0
          TX packets:797 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:81543 (79.6 KiB)  TX bytes:81543 (79.6 KiB)

$ cat /etc/network/interfaces 
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet static
	address 10.0.43.2
	netmask 255.255.255.0
	network 10.0.43.0
	broadcast 10.0.43.255
	gateway 10.0.43.1
	# dns-* options are implemented by the resolvconf package, if installed
	dns-nameservers 192.168.0.1
	dns-search underworld

auto br0
iface br0 inet static
	address 192.168.0.1
	netmask 255.255.255.0
	network 192.168.0.0
	broadcast 192.168.0.255
	bridge-ports eth1 eth2
	bridge_hello 1
	bridge_fd 4
	bridge_maxage 4
	post-up /sbin/route add -net 224.0.0.0 netmask 240.0.0.0 dev br0

Cheers,
Chris



      
