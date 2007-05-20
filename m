From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] improved locking performance in rt_run_flush()
Date: Sun, 20 May 2007 15:11:48 +1000
Message-ID: <E1Hpdhs-00069a-00@gondolin.me.apana.org.au>
References: <20070514.030412.104035740.davem@davemloft.net>
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4016 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758050AbXETFMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 May 2007 01:12:10 -0400
In-Reply-To: <20070514.030412.104035740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
>> 
>> The below patch changes rt_run_flush() to only take each spinlock
>> protecting the rt_hash_table once instead of taking a spinlock for
>> every hash table bucket (and ending up taking the same small set 
>> of locks over and over).

...

> I'm not ignoring it I'm just trying to brainstorm whether there
> is a better way to resolve this inefficiency. :-)

The main problem I see with this is having to walk and free each
chain with the lock held.  We could avoid this if we had a pointer
in struct rtable to chain them up for freeing later.

I just checked and struct rtable is 236 bytes long on 32-bit but
the slab cache pads it to 256 bytes so we've got some free space.
I suspect 64-bit should be similar.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
