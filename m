From: Peter Lieven <pl@dlh.net>
Subject: RFS seems to have incompatiblities with bridged vlans
Date: Mon, 7 Jun 2010 22:36:11 +0200
Message-ID: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zion.dlh.net ([91.198.192.1]:42953 "EHLO mail.dlh.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752573Ab0FGVIE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 17:08:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

i today tried out 2.6.32-rc2 and I see a lot of warning messages like this:

Jun  7 22:33:15 172.21.55.20 kernel: [ 3012.575884] br141 received packet on queue 4, but number of RX queues is 1

The host is a SMP system with 8 cores, so I think there is expected to be one rx queue per CPU, but it seems
the bridge iface has only one.

The br141 config looks like this:

#brctl show br141
bridge name	bridge id		STP enabled	interfaces
br141		8000.001018593cdc	no		eth2.141
							tap0
							tap2

The bridge is basically a bridge between a 802.1q vlan at eth2 and some tap Interfaces bound to
virtual machines on the system.

Peter.