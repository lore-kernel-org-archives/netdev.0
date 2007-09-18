From: Ben Greear <greearb@candelatech.com>
Subject: Quick benchmark for Mellanox 2-port 10Gbe NIC.
Date: Mon, 17 Sep 2007 17:21:03 -0700
Message-ID: <46EF19EF.2030803@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:41541 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753814AbXIRAVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 20:21:05 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l8I0L3WP008592
	for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 17:21:03 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I just managed to get a 2-port Mellanox 10Gbe pci-e NIC working with
2.6.23-rc6 + my hacks.  There are some errors about scheduling
while atomic and such in the management path (ie, querying stats, etc),
but the data path looks pretty good.

At 1500 MTU I was able to send + rx 2.5Gbps on both ports using my
pktgen.

TCP maxed out at about 1.4Gbps send + rx, generated with my proprietary
user-space tool with MTU 1500.  With MTU 8000, I can send + rx about 1.8Gbps.

When I change MTU to 8000 on the NICs, pktgen can send + rx about 4.5Gbps
at 4000 byte pkt sizes.

When sending one one port and receiving on the other, I can send 9+Gbps of
traffic, using MTU of 8000 and pktgen pkt size of 4000.  Using larger pktgen pkt sizes slows traffic down
to around 7Gbps, probably due to extra page allocations.

So, there are some warts to be worked out in the driver, but the
raw performance looks pretty promising!

Take it easy,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

