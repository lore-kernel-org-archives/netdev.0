From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: netem and multiple parameters
Date: Sun, 18 Dec 2011 00:03:02 -0500
Message-ID: <1324184582.8451.430.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:63359 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695Ab1LRFDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Dec 2011 00:03:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  When using netem and desiring multiple characteristics such
as delay and packet loss, is it appropriate to place them on one line?
I've seen examples of doing that while researching but it doesn't seem
to be working for me.  I have a netem qdisc on both egress and ingress
(for a specific reason) each with 25ms delay and 0.1% packet loss:

tc qdisc add dev ifb1 root handle 2 netem delay 25ms 5ms distribution normal loss 0.1% 30%
tc filter add dev eth1 parent 1:0 protocol ip prio 1 u32 match u32 0 0 action mirred egress redirect dev ifb1
tc qdisc add dev ifb0 root handle 1: hfsc default 20
tc class add dev ifb0 parent 1: classid 1:1 hfsc sc rate 1490kbit ul rate 1490kbit
tc class add dev ifb0 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls rate 200kbit
tc qdisc add dev ifb0 parent 1:20 handle 1201 netem delay 25ms 5ms distribution normal loss 0.1% 30%

I see the 50ms delay but, after two runs of 6000 pings, I see no packet
loss whatsoever.  I would have expected about 12 dropped packets:

6570 packets transmitted, 6570 received, 0% packet loss, time 1975920ms
rtt min/avg/max/mdev = 23.983/50.830/75.255/7.101 ms

6536 packets transmitted, 6536 received, 0% packet loss, time 1965211ms
rtt min/avg/max/mdev = 23.298/50.877/74.216/7.064 ms


What have I mangled? Thanks - John
