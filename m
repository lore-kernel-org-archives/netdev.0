From: "Tim Durack" <tdurack@gmail.com>
Subject: Re: r8169 ethernet bonding problems
Date: Fri, 27 Apr 2007 16:53:41 -0400
Message-ID: <9e246b4d0704271353g105ecd62j4f35a6e9027ad590@mail.gmail.com>
References: <9e246b4d0704180552q16b05017wd0d7041c3ce04f46@mail.gmail.com>
	 <20070418181333.GA2261@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:29960 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027AbXD0Uxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 16:53:42 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1022336wxd
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 13:53:41 -0700 (PDT)
In-Reply-To: <20070418181333.GA2261@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> See:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc7/
>
> Please Cc: netdev on success/failure.

Applied suggested patchset to vanilla 2.6.21.

Compiled using .config from linux-image-2.6.21-rc7 pulled down from
http://kernel-archive.buildserver.net/debian-kernel

Compiles, boots.

Bonding does not work reliably. Simple config:

#auto bond0
iface bond0 inet manual
  up ip link set dev $IFACE up
  up echo +eth1 > /sys/class/net/$IFACE/bonding/slaves
  up echo +eth2 > /sys/class/net/$IFACE/bonding/slaves
  up ip link set dev eth1 up
  up ip link set dev eth2 up
  up ip addr add 172.21.255.5/29 dev $IFACE
  down ip addr del 172.21.255.5/29 dev $IFACE
  down ip link set dev eth2 down
  down ip link set dev eth1 down
  down echo -eth2 > /sys/class/net/$IFACE/bonding/slaves
  down echo -eth1 > /sys/class/net/$IFACE/bonding/slaves
  down ip link set dev $IFACE down

Bond comes up, cannot ping unless I manually force promisc on both member links:

ip link set dev eth1 promisc on
ip link set dev eth2 promisc off

Link failover does not work reliably. Carrier-detect appears to be
working, so I don't think that is an issue.


A disturbing problem is mac corruption after "modprobe -r r8169; modprobe r8169"

ip link sh:

2: eth5: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:00:00:00:68:93 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:30:18:ab:68:94 brd ff:ff:ff:ff:ff:ff
4: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:30:18:ab:68:95 brd ff:ff:ff:ff:ff:ff

eth5 mac was 00:30:18:ab:68:93 before the modprobe.

Not sure what's going on here, but I'm starting to think these
interfaces aren't the best in the world...

Tim:>
