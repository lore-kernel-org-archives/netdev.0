From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: fix problem with parallel link
 synchronization mechanism
Date: Wed, 29 Apr 2015 15:09:23 -0400 (EDT)
Message-ID: <20150429.150923.1291697432920867232.davem@davemloft.net>
References: <1430254744-10081-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbbD2TJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 15:09:26 -0400
In-Reply-To: <1430254744-10081-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue, 28 Apr 2015 16:59:04 -0400

> Currently, we try to accumulate arrived packets in the links's
> 'deferred' queue during the parallel link syncronization phase.
> 
> This entails two problems:
> 
> - With an unlucky combination of arriving packets the algorithm
>   may go into a lockstep with the out-of-sequence handling function,
>   where the synch mechanism is adding a packet to the deferred queue,
>   while the out-of-sequence handling is retrieving it again, thus
>   ending up in a loop inside the node_lock scope.
> 
> - Even if this is avoided, the link will very often send out
>   unnecessary protocol messages, in the worst case leading to
>   redundant retransmissions.
> 
> We fix this by just dropping arriving packets on the upcoming link
> during the synchronization phase, thus relying on the retransmission
> protocol to resolve the situation once the two links have arrived to
> a synchronized state.
> 
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
