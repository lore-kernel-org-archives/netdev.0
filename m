From: Ben Greear <greearb@candelatech.com>
Subject: More details on why received UDP packets are treated as errors?
Date: Mon, 29 Jul 2013 11:21:31 -0700
Message-ID: <51F6B2AB.5050607@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40145 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756182Ab3G2SVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 14:21:32 -0400
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r6TILVVL002601
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 29 Jul 2013 11:21:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have a test case on 3.9.9+ (local patches applied) where sending from
VETH interface, through peer VETH bridged (with our own emulator bridge module)
to physical interface, which is then looped to another physical interface (B).
The VETH and the wired B interface are sending UDP traffic to each other.
Routing rules should be configured such that this all works appropriately.

Replacing our bridging module with a user-space bridge has same behaviour.

This setup works on the 3.7.y kernel, but we only get one-way traffic
(B to VETH) on 3.9.9+.

I sniffed the B port, and traffic appears to be sent and received
properly (ie, no checksum errors, etc).  But, our user-space app
shows no received UDP frames on B, and netstat -s gives the
output below.

Is there any way to get more details about what these 'packet receive errors'
are caused by using normal-ish tools?

Udp:
     6827 packets received
     0 packets to unknown port received.
     6172 packet receive errors
     12964 packets sent
     0 receive buffer errors
     0 send buffer errors

Tcp connections also fail to work, and I see these TCP stats.  I'm sure
not all of this is related to the problem at hand, but likely some of it
is.

Tcp:
     81 active connections openings
     11 passive connection openings
     66 failed connection attempts
     0 connection resets received
     17 connections established
     204643 segments received
     229686 segments send out
     465 segments retransmited
     322 bad segments received.
     70 resets sent


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
