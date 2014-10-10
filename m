From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in
 non-interrupt context.
Date: Fri, 10 Oct 2014 01:03:20 -0400 (EDT)
Message-ID: <20141010.010320.1545286759850518718.davem@davemloft.net>
References: <EB9A1CD1-6E1D-409C-89CB-95CC9A5AFC1D@oracle.com>
	<20141010.003628.646817757614430018.davem@davemloft.net>
	<960E9AF5-0319-44C7-9A1C-37EAEE52E78E@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: Raghuram.Kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbaJJFDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 01:03:21 -0400
In-Reply-To: <960E9AF5-0319-44C7-9A1C-37EAEE52E78E@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Date: Thu, 9 Oct 2014 21:56:45 -0700

> Sorry, I used incorrect terminology in my email. My knowledge of LLTX
> is limited and I am still learning. I was not referring to the LLTX, but  about 
> the implementation of  sunvnet transmit path and receive paths without locks. To me that
> means only one thread of execution exists at a given time and I was
> referring to it as single threadedness,  which limits performance on SPARC CMT
> processors today. Using  methods to increase parallelism will help especially
> when the traffic involves multiple connections, mainly from the point of view
> of using multiple vCPUs to perform the processing where possible. 

Let's not speak in generalities, but rather about specifical
implementations of specific things.

Linux's TX path it fully parallelized and multiqueue, so you can have
as many parallel TX threads of control executing over a specific
device as you can provide TX queues.
