From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Defer tx completion processing using
 a wait queue
Date: Tue, 12 Apr 2016 21:12:02 -0400 (EDT)
Message-ID: <20160412.211202.1299929008077475122.davem@davemloft.net>
References: <570D4EBC.60409@linux.vnet.ibm.com>
	<1460491940.6473.592.camel@edumazet-glaptop3.roam.corp.google.com>
	<570D61E7.2090203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tlfalcon@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758402AbcDMBMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 21:12:07 -0400
In-Reply-To: <570D61E7.2090203@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Tue, 12 Apr 2016 16:00:23 -0500

> On 04/12/2016 03:12 PM, Eric Dumazet wrote:
>> On Tue, 2016-04-12 at 14:38 -0500, John Allen wrote:
>>> Moves tx completion processing out of interrupt context, deferring work
>>> using a wait queue. With this work now deferred, we must account for the
>>> possibility that skbs can be sent faster than we can process completion
>>> requests in which case the tx buffer will overflow. If the tx buffer is
>>> full, ibmvnic_xmit will return NETDEV_TX_BUSY and stop the current tx
>>> queue. Subsequently, the queue will be restarted in ibmvnic_complete_tx
>>> when all pending tx completion requests have been cleared.
>> 
>> 1) Why is this needed ?
> 
> In the current ibmvnic implementation, tx completion processing is done in
> interrupt context. Depending on the load, this can block further
> interrupts for a long time. This patch just creates a bottom half so that
> when a tx completion interrupt comes in, we can defer the majority of the
> work and exit interrupt context quickly.

You should use NAPI polling for this, not your own invented
mechanism.
