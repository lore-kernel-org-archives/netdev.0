From: Andi Kleen <ak@suse.de>
Subject: Re: skb_shared_info()
Date: Mon, 14 Aug 2006 09:45:53 +0200
Message-ID: <200608140945.53713.ak@suse.de>
References: <20060808.163915.03600382.davem@davemloft.net> <200608140704.01533.ak@suse.de> <20060814072903.GA14138@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58053 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751658AbWHNHs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 03:48:29 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060814072903.GA14138@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 14 August 2006 09:29, Herbert Xu wrote:
> On Mon, Aug 14, 2006 at 07:04:01AM +0200, Andi Kleen wrote:
> > 
> > Another reason to move it in the sk_buff would be better cache 
> > coloring? Currently on large/small MTU packets it will be always on 
> > the same colors.
> 
> If we went with a fully paged skbs this should be a non-issue, right?

Even for 1.5k MTU? (which is still the most common case after all)

> In a fully paged representation the head would be small which is the
> perfect place to place the skb_shared_info.

If the head is small and allocated with kmalloc then slab should 
color it yes. It won't for big allocations.

-Andi
 
