From: Ben Greear <greearb@candelatech.com>
Subject: Any good documentation on RTNL
Date: Wed, 12 Dec 2012 15:15:38 -0800
Message-ID: <50C9101A.6000906@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39392 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766Ab2LLXPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 18:15:39 -0500
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id qBCNFdZs021099
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 15:15:39 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm wondering if anyone could point me to some documentation on
the finer points of what the rtnl_lock() does?  I can't find anything
overly useful in google or the kernel docs.

For instance, can the packet rx-logic run (on other threads?) while rtnl is held?

How about tx-logic?

In particular, I'm interested to know if it is valid to have
this state:

thread 1 holds RTNL, and blocks on thread 2 due to trying to flush a work-queue.

thread 2 is processing an item on that work-queue, and the work item is sending packets
   (and blocking for up to 200ms timeout trying to flush a wifi driver's queues).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
