From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [RFC] Multi queue support in ethernet/freescale/ucc_geth.c
Date: Thu, 2 Feb 2012 17:42:00 -0500
Message-ID: <4F2B1138.2090004@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>
To: <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:51248 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044Ab2BCAAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 19:00:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Li,

A while back DaveM mentioned that it would be good to
break out the ring allocations[1] in this driver.

I was looking at it, and in the process noticed this:

$ grep 'numQueues.*=' drivers/net/ethernet/freescale/ucc_geth.c 
        .numQueuesTx = 1,
        .numQueuesRx = 1,
$ 

My interpretation of the above is that there is no way
(aside from a code edit) to enable multi queue support.
They are only ever assigned one time, to a value of one.

Assuming I'm not missing something obvious, is the multi
queue support functional and tested, or just old code
that never got tested and subsequently enabled?

The reason I ask, is that the ring allocation code gets rid
of the loop wrapping it, if the driver is really only meant
to ever have just single queues for Rx/Tx. And other areas
of the driver can also be simplified accordingly as well.

Thanks,
Paul.

[1] http://lists.openwall.net/netdev/2010/09/06/45
