From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 0/3] net: Add ftracer to help optimize process
	scheduling based on incomming frame allocations (v3)
Date: Thu, 13 Aug 2009 10:59:17 -0400
Message-ID: <20090813145917.GA16521@hmsreliant.think-freely.org>
References: <20090807202130.GA26677@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, rostedt@goodmis.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38909 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbZHMO7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 10:59:19 -0400
Content-Disposition: inline
In-Reply-To: <20090807202130.GA26677@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
        I put out an RFC about this awhile ago and didn't get any loud screams,
so I've gone ahead and implemented it

        Currently, our network infrastructure allows net device drivers to
allocate skbs based on the the numa node the device itself is local to.  This of
course cuts down on cross numa chatter when the device is DMA-ing network
traffic to the driver.  Unfortuantely no such corresponding infrastrucuture
exists at the process level.  The scheduler has no insight into the numa
locality of incomming data packets for a given process (and arguably it
shouldn't), and so there is every chance that a process will run on a different
numa node than the packets that its receiving lives on, creating cross numa node
traffic.

        This patch aims to provide userspace with the opportunity to optimize
that scheduling.  It consists of a tracepoint and an ftrace module which exports
a history of the packets each process receives, along with the numa node each
packet was received on, as well as the numa node the process was running on when
it copied the buffer to user space.  With this information, exported via the
ftrace infrastructure to user space, a sysadim can identify high prirority
processes, and optimize their scheduling so that they are more likely to run on
the same node that they are primarily receiving data on, thereby cutting down
cross numa node traffic.

Tested by me, working well, applies against the head of the net-next tree


Version 3 change notes:

Respun on davems request to apply to the head of the net-next tree.  No other
changes

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

