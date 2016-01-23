From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sat, 23 Jan 2016 19:48:57 +0000
Message-ID: <20160123194856.GB10826@n2100.arm.linux.org.uk>
References: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk>
 <20160123181526.GD3880@lunn.ch>
 <20160123190622.GA10826@n2100.arm.linux.org.uk>
 <20160123193705.GE3880@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:59018 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbcAWTtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2016 14:49:03 -0500
Content-Disposition: inline
In-Reply-To: <20160123193705.GE3880@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 23, 2016 at 08:37:05PM +0100, Andrew Lunn wrote:
> I'm testing on a 6172. But 6172 and 6176 are both in the same family
> 6352, and share the same driver.

Hmm, can't be that then.

> So you initially have lan1 in an bridge. I don't.

Okay, I've disabled br0 in the debian network/interfaces and rebooted.
This means eth0 (connected to the bridge) is initially down, along with
all the lan interfaces.

root@clearfog:~# brctl show br0
bridge name     bridge id               STP enabled     interfaces
br0             can't get info No such device
root@clearfog:~# ip link set eth0 up
root@clearfog:~# ip link set lan5 up
root@clearfog:~# ip addr add 192.168.254.3/24 dev lan5
root@clearfog:~# ping 192.168.254.254
PING 192.168.254.254 (192.168.254.254) 56(84) bytes of data.
64 bytes from 192.168.254.254: icmp_seq=1 ttl=64 time=1.15 ms
64 bytes from 192.168.254.254: icmp_seq=2 ttl=64 time=0.686 ms
^C
--- 192.168.254.254 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.686/0.921/1.157/0.237 ms
root@clearfog:~# ip addr del 192.168.254.3/24 dev lan5
root@clearfog:~# brctl addbr br0
root@clearfog:~# brctl addif br0 lan5
root@clearfog:~# ip link set br0 up
root@clearfog:~# ip addr add 192.168.254.3/24 dev br0
root@clearfog:~# ping 192.168.254.254
PING 192.168.254.254 (192.168.254.254) 56(84) bytes of data.
64 bytes from 192.168.254.254: icmp_seq=1 ttl=64 time=1.18 ms
^C
--- 192.168.254.254 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.189/1.189/1.189/0.000 ms

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
