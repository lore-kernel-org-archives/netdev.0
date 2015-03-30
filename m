From: Erik Hugne <erik.hugne@ericsson.com>
Subject: tc ingress filters not applied
Date: Mon, 30 Mar 2015 16:15:23 +0200
Message-ID: <20150330141523.GQ23551@haze>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:45855 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044AbbC3OTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 10:19:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm having troubles with TC policing, the ingress filters does not seem to be
applied.

node1 ~ # tc qdisc add dev eth0 ingress
node1 ~ # tc qdisc ls
qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc ingress ffff: dev eth0 parent ffff:fff1 ---------------- 
//Test 1: Limit TIPC low importance traffic to 100mbit
node1 ~ # tc filter add dev eth0 parent ffff: protocol tipc u32 match u8 0 1E at
 0 police rate 100mbit buffer 10k drop flowid :1
node1 ~ # tc filter show dev eth0
node1 ~ # 

//Test 2: Limit ICMP to 20kbit
node1 ~ # tc filter add dev eth0 parent ffff: protocol ip prio 20 u32 match ip p
rotocol 1 0xff police rate 20kbit buffer 10k drop flowid :2
node1 ~ # tc filter show dev eth0
node1 ~ # 

There are no errors in dmesg, just silence.
Are my filter rules wrong, or is ingress filtering broken?

Kernel: net-next/latest 
iproute2: shemminger/master

//E
