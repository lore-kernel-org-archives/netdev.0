From: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Subject: Problem facing with ipv6 router advertisement in kernel-3.0.26
Date: Wed, 18 Jul 2012 13:02:02 +0000
Message-ID: <4A71D24947E78D43BC584A7CD4391A41017DCF73@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:39297
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752043Ab2GRNC3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2012 09:02:29 -0400
Received: from mail73-ch1 (localhost [127.0.0.1])	by mail73-ch1-R.bigfish.com
 (Postfix) with ESMTP id 26BB638008F	for <netdev@vger.kernel.org>; Wed, 18 Jul
 2012 13:02:28 +0000 (UTC)
Received: from CH1EHSMHS004.bigfish.com (snatpool1.int.messaging.microsoft.com
 [10.43.68.249])	by mail73-ch1.bigfish.com (Postfix) with ESMTP id 80E0CA004A
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 13:02:26 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

       As per RFC, curhoplimit of router advertisement(ra) should be kept as hoplimit for the routing table entry. It expects that the hoplimit of a routing path should not affected if a ra comes for the path with curhoplimit is 0. But in the case of kernel-3.0.26, the value is altered to 255. But it happens only in the router cache(#ip -6 route show cached) not in the main routing table (#ip -6 route show). But if I disable 'multiple routing table' option while building the kernel, it also affects the main routing table.

	Timer expiry for a routing table entry. I am facing this scenario. I have the gc_interval value 30 seconds. I am receinving a ra with preferred lifetime 20 seconds. So the routing table entry expirs and removed from the routing table in 20 seconds. But the cache remains with the expired routing entry till next flush.

	As per my knowledge MTU value is not stored in the routing table. I can see the the MTU value in routing cache but not in the main routing table. So in my case, once the routing cahce is flushed, the kernel not properly fragments the packet according to the MTU value even the timer doesn't expire. I don't know am I right or wrong. I will tell what is happening. I have a router connected with a target board. The router sends a ra with mtu 1200 and sends a ICMP_REQUEST with length 1500. And it expects the target board to send ICMP_REPLY as fragmented into two packets (1200 and 300). But the target board does correctly if the cache is present. But once the cache is flushed, it fails.

Note: I am using Kernel-3.0.26 for arm architecture.

Thank you,

--Regards,
K.Balakumaran
