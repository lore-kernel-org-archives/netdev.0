From: Mithlesh Thukral <mithlesh@linsyssoft.com>
Subject: Doubt about locking in ixgb driver
Date: Wed, 9 Aug 2006 18:54:14 +0530
Message-ID: <200608091854.14584.mithlesh@linsyssoft.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:15018 "EHLO
	svr68.ehostpros.com") by vger.kernel.org with ESMTP
	id S1161187AbWHJLmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 07:42:21 -0400
Received: from [59.95.4.207] (helo=titan.linsyssoft.com)
	by svr68.ehostpros.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.52)
	id 1GB8va-00024B-3f
	for netdev@vger.kernel.org; Thu, 10 Aug 2006 04:42:19 -0700
Received: from athena (athena [192.168.1.31] (may be forged))
	by titan.linsyssoft.com (8.13.1/8.13.1) with ESMTP id k7ABNSNR005486
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 16:53:28 +0530
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi all,

The transmit functions of ethernet drivers (dev->hard_start_xmit) are 
protected to prevent multiple execution of transmits going  in parallel. The 
general scheme used by most of driver is :
1. Reset NETIF_F_LLTX flag in dev->features and then use kernel locking given 
through HARD_TX_LOCK (net/core/dev.c:3417)
		OR
2. Use a internal lock of driver generally kept in adapter to prevent multiple 
accesses.

In ixgb driver (drivers/net/ixgb/), there is a lock in adapter of driver 
(adapter->tx_lock). But this is left before the ixgb_xmit_frame() function 
returns. The access to adapter->tx_ring.next_to_use which i suppose will be 
the index of next element to use from tx_ring is accessed outside the area 
where lock is held. What will prevent race condition during accessing 
adapter->tx_ring.next_to_use ?
How does multiple instances of xmit not run or multiple instances of xmit 
running is fine ?

Regards,
Mithlesh Thukral
