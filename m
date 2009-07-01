From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Wed, 1 Jul 2009 08:27:32 +0200
Message-ID: <20090701062732.GK6760@one.firstfloor.org>
References: <87eit3l7y6.fsf@basil.nowhere.org> <20090701033924.GA29762@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, jolsa@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com, eric.dumazet@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49781 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbZGAG1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 02:27:34 -0400
Content-Disposition: inline
In-Reply-To: <20090701033924.GA29762@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 11:39:24AM +0800, Herbert Xu wrote:
> Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > At least on x86 I can't see how it happens. mb() is only a compile
> > time barrier and the compiler doesn't optimize over indirect callbacks
> > like __pollwait() anyways.
> 
> mb() does more than just a compiler barrier, it also issues mfence.

mfence is not needed for normal C code (not using non temporal
stores) in the Linux memory model on x86 and is a no-op. Only the compile
time barrier matters.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
