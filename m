From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 11572] New: udp: unbalanced unlock bug in
 udp_queue_rcv_skb with ipsec
Date: Mon, 15 Sep 2008 11:50:25 -0700 (PDT)
Message-ID: <20080915.115025.69496005.davem@davemloft.net>
References: <bug-11572-2647@http.bugzilla.kernel.org/>
	<20080915183419.GA12978@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752687AbYIOSuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 14:50:32 -0400
In-Reply-To: <20080915183419.GA12978@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 15 Sep 2008 11:34:20 -0700

> udp: Fix rcv socket locking
> 
> The previous patch in response to the recursive locking on IPsec
> reception is broken as it tries to drop the BH socket lock while in
> user context.
> 
> This patch fixes it by shrinking the section protected by the
> socket lock to sock_queue_rcv_skb only.  The only reason we added
> the lock is for the accounting which happens in that function.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, I'll have to queue this up to -stable as well.

Thanks!
