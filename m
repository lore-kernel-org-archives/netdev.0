From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] xen-netback: bookkeep number of active queues
 in our own module
Date: Wed, 25 Jun 2014 16:00:14 -0700 (PDT)
Message-ID: <20140625.160014.56739986859754696.davem@davemloft.net>
References: <1403517017-7016-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	boris.ostrovsky@oracle.com, ian.campbell@citrix.com,
	paul.durrant@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756178AbaFYXAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 19:00:15 -0400
In-Reply-To: <1403517017-7016-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 23 Jun 2014 10:50:17 +0100

> The original code uses netdev->real_num_tx_queues to bookkeep number of
> queues and invokes netif_set_real_num_tx_queues to set the number of
> queues. However, netif_set_real_num_tx_queues doesn't allow
> real_num_tx_queues to be smaller than 1, which means setting the number
> to 0 will not work and real_num_tx_queues is untouched.
> 
> This is bogus when xenvif_free is invoked before any number of queues is
> allocated. That function needs to iterate through all queues to free
> resources. Using the wrong number of queues results in NULL pointer
> dereference.
> 
> So we bookkeep the number of queues in xen-netback to solve this
> problem. This fixes a regression introduced by multiqueue patchset in
> 3.16-rc1.
> 
> There's another bug in original code that the real number of RX queues
> is never set. In current Xen multiqueue design, the number of TX queues
> and RX queues are in fact the same. We need to set the numbers of TX and
> RX queues to the same value.
> 
> Also remove xenvif_select_queue and leave queue selection to core
> driver, as suggested by David Miller.
> 
> Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Applied, thank you.
