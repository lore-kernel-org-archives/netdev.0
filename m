From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v7] xps: Transmit Packet Steering
Date: Wed, 24 Nov 2010 11:45:34 -0800 (PST)
Message-ID: <20101124.114534.15255941.davem@davemloft.net>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752960Ab0KXTpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:45:09 -0500
In-Reply-To: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 21 Nov 2010 15:17:27 -0800 (PST)

> This patch implements transmit packet steering (XPS) for multiqueue
> devices.  XPS selects a transmit queue during packet transmission based
> on configuration.  This is done by mapping the CPU transmitting the
> packet to a queue.  This is the transmit side analogue to RPS-- where
> RPS is selecting a CPU based on receive queue, XPS selects a queue
> based on the CPU (previously there was an XPS patch from Eric
> Dumazet, but that might more appropriately be called transmit completion
> steering).
> 
> Each transmit queue can be associated with a number of CPUs which will
> use the queue to send packets.  This is configured as a CPU mask on a
> per queue basis in:
> 
> /sys/class/net/eth<n>/queues/tx-<n>/xps_cpus
> 
> The mappings are stored per device in an inverted data structure that
> maps CPUs to queues.  In the netdevice structure this is an array of
> num_possible_cpu structures where each structure holds and array of
> queue_indexes for queues which that CPU can use.
> 
> The benefits of XPS are improved locality in the per queue data
> structures.  Also, transmit completions are more likely to be done
> nearer to the sending thread, so this should promote locality back
> to the socket on free (e.g. UDP).  The benefits of XPS are dependent on
> cache hierarchy, application load, and other factors.  XPS would
> nominally be configured so that a queue would only be shared by CPUs
> which are sharing a cache, the degenerative configuration woud be that
> each CPU has it's own queue.
> 
> Below are some benchmark results which show the potential benfit of
> this patch.  The netperf test has 500 instances of netperf TCP_RR test
> with 1 byte req. and resp.
> 
> bnx2x on 16 core AMD
>    XPS (16 queues, 1 TX queue per CPU)  1234K at 100% CPU
>    No XPS (16 queues)                   996K at 100% CPU
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, please consider Eric's feedback about map NUMA node placement.
