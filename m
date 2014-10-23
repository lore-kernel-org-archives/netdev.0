From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] macvlan: fix a race on port dismantle and possible
 skb leaks
Date: Thu, 23 Oct 2014 11:28:58 +0800
Message-ID: <20141023032858.GA1836@gondor.apana.org.au>
References: <1414032226.2094.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:53683 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932619AbaJWD3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 23:29:04 -0400
Content-Disposition: inline
In-Reply-To: <1414032226.2094.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 07:43:46PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> We need to cancel the work queue after rcu grace period,
> otherwise it can be rescheduled by incoming packets.
> 
> We need to purge queue if some skbs are still in it.
> 
> We can use __skb_queue_head_init() variant in
> macvlan_process_broadcast()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 412ca1550cbec ("macvlan: Move broadcasts into a work queue")
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Good catch! Your fix looks good to me.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
