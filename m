From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Wed, 1 Jul 2009 09:22:26 +0200
Message-ID: <20090701072226.GN6760@one.firstfloor.org>
References: <87eit3l7y6.fsf@basil.nowhere.org> <20090701033924.GA29762@gondor.apana.org.au> <20090701062732.GK6760@one.firstfloor.org> <20090701070332.GA31103@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, jolsa@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com, eric.dumazet@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54395 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbZGAHWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 03:22:23 -0400
Content-Disposition: inline
In-Reply-To: <20090701070332.GA31103@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 03:03:32PM +0800, Herbert Xu wrote:
> On Wed, Jul 01, 2009 at 08:27:32AM +0200, Andi Kleen wrote:
> >
> > mfence is not needed for normal C code (not using non temporal
> > stores) in the Linux memory model on x86 and is a no-op. Only the compile
> > time barrier matters.
> 
> In that case this bug needs to be digged deeper regardless of
> this patch.

Agreed.

I suspect the reordering of the wake queue tests might makes a difference, but
in this case to ensure they are always tested in the proper order by
the compiler would need more smp_rmb()s

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
