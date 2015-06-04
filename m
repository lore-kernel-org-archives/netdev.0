From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Thu, 4 Jun 2015 09:27:27 -0700
Message-ID: <20150604162727.GA2670@roeck-us.net>
References: <20150514055824.GB6058@gondor.apana.org.au>
 <20150515.130257.1322224469755323983.davem@redhat.com>
 <20150516131628.GA981@gondor.apana.org.au>
 <20150516.171019.1206903516753105739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:57448 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752341AbbFDQ1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 12:27:32 -0400
Content-Disposition: inline
In-Reply-To: <20150516.171019.1206903516753105739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 16, 2015 at 05:10:19PM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 16 May 2015 21:16:28 +0800
> 
> > On Fri, May 15, 2015 at 01:02:57PM -0400, David Miller wrote:
> >> From: Herbert Xu <herbert@gondor.apana.org.au>
> >> Date: Thu, 14 May 2015 13:58:24 +0800
> >> 
> >> > The current rhashtable rehash code is buggy and can't deal with
> >> > parallel insertions/removals without corrupting the hash table.
> >> > 
> >> > This patch disables it by partially reverting
> >> > c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink: eliminate
> >> > nl_sk_hash_lock").
> >> > 
> >> > This patch also removes a bogus socket lock introduced by that
> >> > very same patch.
> >> > 
> >> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >> 
> >> Herbert, if you agree with me in the other thread that the lock_sock()
> >> or something like it has to remain, you'll need to respin this.
> > 
> > Actually I think this one is OK because I'm replacing it with the
> > hash table mutex which is just like the previous global lock except
> > that it is per-family.  As you cannot change the family on a netlink
> > socket this should be good enough.
> > 
> > But the changelog message is wrong so here is an updated version.
> > 
> > Cheers,
> > 
> > ---8<---
> > The current rhashtable rehash code is buggy and can't deal with
> > parallel insertions/removals without corrupting the hash table.
> > 
> > This patch disables it by partially reverting
> > c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink: eliminate
> > nl_sk_hash_lock").
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Ok, I've queued this up for -stable, thanks Herbert.
> 
Hi David,

sorry for bothering you - I don't see this patch in any of your trees,
and it is marked as "changes requested" in patchwork. Did I look
at the wrong places, do you still plan to apply the patch as-is,
or do you expect some changes ?

As side info, I have been trying to track down the getaddrinfo
hang problem observed by others, which we see in 3.19.4 and 4.0.4.

Thanks,
Guenter
