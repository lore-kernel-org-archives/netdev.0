From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: airo: inconsistent {hardirq-on-W} -> {in-hardirq-W} usage.
Date: Tue, 8 Aug 2006 22:52:22 +1000
Message-ID: <20060808125222.GA15855@gondor.apana.org.au>
References: <20060808094410.GA29313@ee.oulu.fi> <E1GAPZF-0003w4-00@gondolin.me.apana.org.au> <20060808113851.GA17861@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:23301 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964876AbWHHMwc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 08:52:32 -0400
To: Pekka Pietikainen <pp@ee.oulu.fi>
Content-Disposition: inline
In-Reply-To: <20060808113851.GA17861@ee.oulu.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 02:38:51PM +0300, Pekka Pietikainen wrote:
>
> Hmm... I retried with a 2.6.18rc4-based rawhide kernel and the warning
> is still there, previous one was rc3-git7.

Are you sure it's the same warning? The one you quoted earlier is
caused by the lock validator mixing up spin locks from different
skb_buff_head objects.  This is fixed by

commit 76f10ad0e67cbc6ded2ee143e5188e0b7ff9fb15
Author: Arjan van de Ven <arjan@linux.intel.com>
Date:   Wed Aug 2 14:06:55 2006 -0700

    [NET]: Remove lockdep_set_class() call from skb_queue_head_init().

which is definitely upstream.

> Could be http://marc.theaimsgroup.com/?l=linux-netdev&m=115461336523555&w=2
> which isn't upstream yet, right?

That's a separate bug fix which should produce an entirely different
warning.  Although I concede that this patch would make your original
warning look slightly different :)

John, could you please push this to Jeff? Thanks.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
