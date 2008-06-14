From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: CARP: Common Address Redundancy Protocol for Linux kernel release.
Date: Sat, 14 Jun 2008 18:04:32 +0400
Message-ID: <20080614140432.GA9692@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37987 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754236AbYFNOEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jun 2008 10:04:20 -0400
Received: from 2ka.mipt.ru (localhost [127.0.0.1])
	by 2ka.mipt.ru (8.14.1/8.14.1) with ESMTP id m5EE4WRV019470
	for <netdev@vger.kernel.org>; Sat, 14 Jun 2008 18:04:32 +0400
Received: (from johnpol@localhost)
	by 2ka.mipt.ru (8.14.1/8.12.1/Submit) id m5EE4WRf019469
	for netdev@vger.kernel.org; Sat, 14 Jun 2008 18:04:32 +0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

This is not a new project, and it has number of pros and cons to be in
kernel, so I post a note about it here in case people are interested to
create high-avaliable systems with multiple machines.

CARP is an improved version of the Virtual Router Redundancy Protocol
(VRRP) standard. The latest protocol to help provide high availability
and network redundancy, it was developed because router giant Cisco
Systems believes that its Hot Standby Router Protocol (HSRP) patent
covers some of the same technical areas as VRRP.

CARP is cryptographically secure, since it uses hmac to protect its
content. It also does not have replay message attack vector which exists
in OpenBSD implementation (its practical application is questionable
though).

Main advantage over hearbeat-like approaches is ability to scale to
whatever you need number of nodes without needs for persitent connection
(wired, serial or whatever else) between them, the same media as for
data transfer is used (iirc heartbeat 2 does not have it problem?).
Advantage over userspace CARP solution (and heartbeat too) is ability to
control network device on behalf of which data is broadcasted (like
create persistent MAC address between nodes). Aliasing is not a solution
in multiple cases.

CARP configuation is pretty trivial:
$ tar -zxf carp_latest.tar.gz
$ cd carp
$ make

# insmod ip_carp.ko
# modprobe cn
# insmod carp_conn.ko
# ifconfig carp0 up
# carp_conn_daemon -m master.sh -b backup.sh

And the same on all other machines.
Each script as you got from its name is executed when node becomes
master or backup one, you can put there firewall rule changes, traffic
shaping setup, network daemon start/stop scripts and whatever you like.

CARP homepage:
http://tservice.net.ru/~s0mbre/old/?section=projects&item=carp

-- 
	Evgeniy Polyakov
