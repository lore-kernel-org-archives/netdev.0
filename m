From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Fix RSS ring refill race condition
Date: Wed, 21 Mar 2012 21:58:24 -0400 (EDT)
Message-ID: <20120321.215824.1259388773873717864.davem@davemloft.net>
References: <1332380314-14198-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab2CVB6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 21:58:32 -0400
In-Reply-To: <1332380314-14198-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 21 Mar 2012 17:38:33 -0800

> The RSS feature in tg3 hardware has only one rx producer ring for all
> RSS rings.  NAPI vector 1 is special and handles the refilling of the
> rx producer ring on behalf of all RSS rings.  There is a race condition
> between these RSS NAPIs and the NAPI[1].  If NAPI[1] finishes checking
> for refill and then another RSS ring empties the rx producer ring
> before NAPI[1] exits NAPI, the chip will be completely out of SKBs in
> the rx producer ring.
> 
> We fix this by adding a flag tp->rx_refill and rely on napi_schedule()/
> napi_complete() to help synchronize it to close the race condition.
> 
> Update driver version to 3.123.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
