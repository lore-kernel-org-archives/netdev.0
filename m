From: Meelis Roos <mroos@linux.ee>
Subject: Wrong IPv4 source address selected
Date: Sat, 10 Jun 2006 16:30:21 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0606101621540.22354@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:49036 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1751517AbWFJNaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2006 09:30:23 -0400
Received: from math.ut.ee (localhost [IPv6:::1])
	by math.ut.ee (8.12.8+Sun/8.12.8/math-1.2) with ESMTP id k5ADULfU004092
	for <netdev@vger.kernel.org>; Sat, 10 Jun 2006 16:30:21 +0300 (EEST)
Received: from localhost (mroos@localhost)
	by math.ut.ee (8.12.8+Sun/8.12.2/Submit) with ESMTP id k5ADULT9004089
	for <netdev@vger.kernel.org>; Sat, 10 Jun 2006 16:30:21 +0300 (EEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is 2.6.17-rc6 running on a 32-bit ppc (the same ARC=ppc PReP 
machine that had the x_tables problem, so it has the x_tables 
alignment first fix too).

The problem: IPv4 source addresses are sometimes selected wrong (packets 
are sent to the internal 172.30 network with external 193.40 source 
address). I have seen this with ARP requests for 172.30.0.x addresses 
and UDP multicast traffic (avahi query from 193.40.37.61:5353 to 
224.0.0.251:5353 on eth1).

I have 2 physical network interfaces (+ loopback + unconfiured sit0)

2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen 1000
     link/ether 08:00:3e:28:c4:a2 brd ff:ff:ff:ff:ff:ff
     inet 193.40.37.61/23 brd 193.40.37.255 scope global eth0
     inet6 2001:bb8:2002:2400:a00:3eff:fe28:c4a2/64 scope global dynamic
        valid_lft 2591964sec preferred_lft 604764sec
     inet6 fe80::a00:3eff:fe28:c4a2/64 scope link
        valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qlen 1000
     link/ether 00:00:94:7a:31:8c brd ff:ff:ff:ff:ff:ff
     inet 172.30.0.1/24 brd 172.30.0.255 scope global eth1
     inet6 fe80::200:94ff:fe7a:318c/64 scope link
        valid_lft forever preferred_lft forever

ip route ls:
172.30.0.0/24 dev eth1  proto kernel  scope link  src 172.30.0.1 
193.40.36.0/23 dev eth0  proto kernel  scope link  src 193.40.37.61 
default via 193.40.36.1 dev eth0

-- 
Meelis Roos (mroos@linux.ee)
