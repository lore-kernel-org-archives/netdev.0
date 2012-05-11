From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: fix losing of NEQ events when one event occurred
 early
Date: Thu, 10 May 2012 22:46:03 -0400 (EDT)
Message-ID: <20120510.224603.1777168443514351915.davem@davemloft.net>
References: <20120509.202913.886545227635873372.davem@davemloft.net>
	<1336658453-687-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758844Ab2EKCqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 22:46:07 -0400
In-Reply-To: <1336658453-687-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Thu, 10 May 2012 11:00:53 -0300

> The NEQ interrupt is only triggered when there was no previous pending
> interrupt. If we request irq handling after an interrupt has occurred,
> we will never get an interrupt until we call H_RESET_EVENTS.
> 
> Events seem to be cleared when we first register the NEQ. So, when we
> requested irq handling right after registering it, a possible race with
> an interrupt was much less likely. Now, there is a chance we may lose
> this race and never get any events.
> 
> The fix here is to poll and acknowledge any events that might have
> happened right after registering the irq handler.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>

Applied.
