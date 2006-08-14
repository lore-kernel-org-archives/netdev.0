From: Andi Kleen <ak@suse.de>
Subject: Re: skb_shared_info()
Date: Mon, 14 Aug 2006 10:18:05 +0200
Message-ID: <200608141018.05649.ak@suse.de>
References: <20060808.163915.03600382.davem@davemloft.net> <200608140945.53713.ak@suse.de> <20060814075045.GA1437@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:38548 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751931AbWHNISR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 04:18:17 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060814075045.GA1437@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 14 August 2006 09:50, Herbert Xu wrote:
> On Mon, Aug 14, 2006 at 09:45:53AM +0200, Andi Kleen wrote:
> > 
> > Even for 1.5k MTU? (which is still the most common case after all)
> 
> Ideally they would stay in kmalloc memory.  Could you explain the cache
> colouring problem for 1500-byte packets?

kmalloc rounds the 1.5k up to 2k and with that exactly two objects
fit into a 4k page. With that slab doesn't have any space left
to do cache coloring.

-Andi
