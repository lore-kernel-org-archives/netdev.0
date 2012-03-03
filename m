From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: qdisc overlimits not matching class overlimits
Date: Sat, 03 Mar 2012 00:24:27 -0500
Message-ID: <1330752267.4671.187.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:57698 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835Ab2CCFYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2012 00:24:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  We are using HFSC on IFB interfaces.  Both ingress and
egress are redirected but to different IFB interfaces.  The ul is set
quite high but we are still seeing overlimits on the qdiscs:

qdisc hfsc 62: dev ifb0 root default 10
 Sent 14655563 bytes 109780 pkt (dropped 0, overlimits 27220 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc hfsc 60: dev ifb1 root default 10
 Sent 129779537 bytes 156700 pkt (dropped 0, overlimits 87615 requeues 1)
 rate 0bit 0pps backlog 0b 0p requeues 1

However, we are not seeing any overlimits on the classes. Is this
normal? Does it indicate any kind of problem?

class hfsc 60: root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 2

class hfsc 60:1 parent 60: ls m1 0bit d 0us m2 97500Kbit ul m1 0bit d 0us m2 97500Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 100737 work 138063971 bytes level 1

class hfsc 60:10 parent 60:1 leaf 6010: rt m1 0bit d 0us m2 100000bit ls m1 0bit d 0us m2 500000bit
 Sent 69727577 bytes 90314 pkt (dropped 33, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 52077 work 69727577 bytes rtwork 2156866 bytes level 0

class hfsc 60:20 parent 60:1 leaf 6020: rt m1 0bit d 0us m2 512000bit ls m1 0bit d 0us m2 3000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 0

class hfsc 60:30 parent 60:1 leaf 6030: rt m1 0bit d 0us m2 200000bit ls m1 0bit d 0us m2 1000Kbit
 Sent 581340 bytes 1141 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 990 work 581340 bytes rtwork 137868 bytes level 0

class hfsc 60:40 parent 60:1 leaf 6040: rt m1 0bit d 0us m2 688000bit ls m1 0bit d 0us m2 2000Kbit
 Sent 67755054 bytes 89964 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 53911 work 67755054 bytes rtwork 7671157 bytes level 0

class hfsc 62: root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 2

class hfsc 62:10 parent 62:1 leaf 6210: rt m1 0bit d 0us m2 100000bit ls m1 0bit d 0us m2 500000bit
 Sent 42766400 bytes 395980 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 231623 work 42766400 bytes rtwork 5486655 bytes level 0

class hfsc 62:1 parent 62: ls m1 0bit d 0us m2 97500Kbit ul m1 0bit d 0us m2 97500Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 302564 work 54738753 bytes level 1

class hfsc 62:20 parent 62:1 leaf 6220: rt m1 0bit d 0us m2 512000bit ls m1 0bit d 0us m2 3000Kbit
 Sent 6248 bytes 155 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 155 work 6248 bytes rtwork 6248 bytes level 0

class hfsc 62:30 parent 62:1 leaf 6230: rt m1 0bit d 0us m2 200000bit ls m1 0bit d 0us m2 1000Kbit
 Sent 219309 bytes 1587 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 1587 work 219309 bytes rtwork 159354 bytes level 0

class hfsc 62:40 parent 62:1 leaf 6240: rt m1 0bit d 0us m2 688000bit ls m1 0bit d 0us m2 2000Kbit
 Sent 11207094 bytes 70428 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 70143 work 11207094 bytes rtwork 9681685 bytes level 0

class hfsc 62:50 parent 62:1 leaf 6250: rt m1 0bit d 0us m2 45000Kbit
 Sent 539702 bytes 1865 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 work 539702 bytes rtwork 539702 bytes level 0
