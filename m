From: Ben Greear <greearb@candelatech.com>
Subject: MTU and TCP transmit offload.
Date: Wed, 21 Sep 2011 14:06:54 -0700
Message-ID: <4E7A51EE.8010403@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60951 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab1IUVGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 17:06:55 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p8LL6sPO009958
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Sep 2011 14:06:54 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We saw something interesting while doing some testing
on 3.0.4.

We configured 2 Ethernet NICs with standard 1500 MTU, and added
a mac-vlan on each, with MTU of 300.  The goal was to generate as
many ~300 byte TCP packets as possible, for load testing purposes.
We configured our tool to open sockets on the mac-vlans and send/receive
TCP (IPv4) traffic.

This actually seems to work quite nicely, allowing user-space to
do large writes (24k in our case), and it appears have lots of
small packets on the wire.  We still need to sniff with external
system to verify this..but packets-per-second counters look good.

Evidently this all works because macvlans know that the NIC
can do TSO, and the '300' MTU is passed in the big packet
given to the NIC.

This got me thinking...at least for my purposes, it would be
nice to have a per-socket 'MTU' setting.  The idea is that
you could ask the NIC to do the TSO at whatever 'mtu' you
wanted, without having to resort to mac-vlans with artificially
small MTU.

So, is there any interest in supporting such a socket option?

I can't think of any use besides TCP traffic load testing, but
perhaps someone else can think of one?  Or, is load-testing
enough?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
