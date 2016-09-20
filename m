From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC 2/6] rhashtable: Call library function
 alloc_bucket_locks
Date: Tue, 20 Sep 2016 09:49:37 +0800
Message-ID: <20160920014937.GA18287@gondor.apana.org.au>
References: <1473463197-3076903-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
        tgraf@suug.ch
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:41041 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752263AbcITBtu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 21:49:50 -0400
Content-Disposition: inline
In-Reply-To: <1473463197-3076903-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> To allocate the array of bucket locks for the hash table we now
> call library function alloc_bucket_spinlocks. This function is
> based on the old alloc_bucket_locks in rhashtable and should
> produce the same effect.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

This conflicts with the work I'm doing to fix the resize ENOMEM
issue.  I'll be making the hashtable as well as the spinlock table
nested, in which case you must not directly dereference it as an
array.

If you're just trying to share the spinlocks for another purpose,
what we can do is provide a helper function to return the right
lock for a given key/object.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
