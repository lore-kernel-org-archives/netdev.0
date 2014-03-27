From: clsoto@linux.vnet.ibm.com
Subject: [Patch 0/3] Hangs with IPoIB when doing PCI error injection
Date: Thu, 27 Mar 2014 09:28:13 -0500
Message-ID: <20140327142813.535289178@linux.vnet.ibm.com>
Cc: brking@linux.vnet.ibm.com
To: clsoto@linux.vnet.ibm.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [32.97.110.57] ([32.97.110.57]:60982 "HELO
	jupiter1-lp2.austin.ibm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1756892AbaC0Ocp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 10:32:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to resolve some hangs we are seeing when doing PCI error injection
to Mellanox Infiniband cards. With this patch we make mlx4 driver send an IB_EVENT_DEVICE_FATAL 
to the users and added this event to event handlers to avoid these hangs. 
If IPoIB is in connected mode, then added to cm an event handler and tried to 
make sure that when it sees the fatal event it does not try to send anymore packet because
it will not receive any more completions or interrupts. 

 infiniband/core/cm.c               |   43 +++++++++++++++++++++++++++++++++++++
 infiniband/core/multicast.c        |    1
 infiniband/core/sa_query.c         |    1
 infiniband/ulp/ipoib/ipoib_verbs.c |    1
 net/ethernet/mellanox/mlx4/main.c  |    6 +++++

Carol Soto

-- 
