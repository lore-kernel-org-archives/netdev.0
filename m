From: Ben Greear <greearb@candelatech.com>
Subject: TCP funny-ness when over-driving a 1Gbps link.
Date: Thu, 19 May 2011 15:47:14 -0700
Message-ID: <4DD59DF2.2070707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49109 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932323Ab1ESWrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:47:15 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p4JMlFIm024257
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:47:15 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed something that struck me as a bit weird today,
but perhaps it's normal.

I was using our application to create 3 TCP streams from one port to
another (1Gbps, igb driver), running through a network emulator.
Traffic is flowing bi-directional in each connection.

I am doing 24k byte writes per system call.  I tried 100ms, 10ms, and 1ms
latency (one-way) in the emulator, but behaviour is similar in each case.
The rest of this info was gathered with 1ms delay in the emulator.

If I ask all 3 connections to run 1Gbps, netstat shows 30+GB in the
sending queues and 1+ second latency (user-space to user-space).  Aggregate
throughput is around 700Mbps in each direction.

But, if I ask each of the connections to run at 300Mbps, latency averages
2ms and each connection runs right at 300Mbps (950Mbps or so on the wire).

It seems that when you over-drive the link, things back up and perform
quite badly over-all.

This is a core-i7 3.2Ghz with 12GB RAM, Fedora 14, 2.6.38.6 kernel
(with some hacks), 64-bit OS and user-space app.  Quick testing on 2.6.36.3
showed similar results, so I don't think it's a regression.

I am curious if others see similar results?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

