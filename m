From: Ben Greear <greearb@candelatech.com>
Subject: pktgen performance hit due to memset.
Date: Fri, 23 Jul 2010 16:14:19 -0700
Message-ID: <4C4A224B.8080806@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48374 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965Ab0GWXOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 19:14:21 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o6NNEKH0031659
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 23 Jul 2010 16:14:20 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some time back, someone added some memset() calls to pktgen to
keep from leaking memory contents to the network.

At least in our modified version of pktgen, this caused about 25%
performance degradation when sending 1514 byte pkts (multi-pkt == 0)
on a pair of 10G ports.  It was easy enough to comment these memset
calls out of course.

I don't mind if this patch stays in,
but thought I'd post my findings in case anyone else wonders why
their pktgen slowed down...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

