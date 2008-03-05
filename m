From: therbert@google.com (Tom Herbert)
Subject: RFC [PATCH net-2.6 0/6] net: Software RSS implementation
Date: Wed,  5 Mar 2008 12:51:16 -0800 (PST)
Message-ID: <20080305205116.5737141256E@localhost>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:9600 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755106AbYCEUva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 15:51:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This patch set contains code to support software Receive Side Scaling (RSS) for the networking receive path.  We have implemented two variants of RSS that addresses some issues we have seen with scaling networking:

1) The napi poll function for a device can be scheduled on a different CPU than the harware interrupt is received.  On architectures where the hardware interrupt is pinned on a single CPU, this allows us to round robin NAPI processing over a set of CPUs to balance the network processing load.

2) Packets received in the NAPI poll function for a NIC can be queued to other CPUs for stack processing (starting from netif_receive_skb).  We use a typical 4-tuple hash to direct packets on a connection to the same CPU.  This mechanism introduces some parallelism into the receive path which in turn increases our packets per second rate.

In this implementation we added the capability for a softirq to be scheduled on one CPU from another CPU; an IPI is used to kick processing on the target CPU.  Both variants of RSS allow a CPU mask which is set per device that indicates which CPUs are eligible for RSS.

These patches are done in the general networking code and do not require any changes to device drivers.  In particular, they are useful with devices that don't have support for hardware RSS.

I would appreciate any comments on this approach, escpecially if there are any ideas for improvement or related work.

Thanks,

Tom Herbert <therbert@google.com>

