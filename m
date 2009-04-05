From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
 implementation & Netlink protocol
Date: Sun, 05 Apr 2009 02:56:21 -0700 (PDT)
Message-ID: <20090405.025621.262216979.davem@davemloft.net>
References: <20090402095957.GA30799@gondor.apana.org.au>
	<49D4CECA.3010703@trash.net>
	<20090402144549.GA764@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, nhorman@tuxdriver.com, zbr@ioremap.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33552
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753390AbZDEJ4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 05:56:32 -0400
In-Reply-To: <20090402144549.GA764@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 2 Apr 2009 22:45:49 +0800

> On Thu, Apr 02, 2009 at 04:42:18PM +0200, Patrick McHardy wrote:
> >
> > Actually we should be fine since the current netlink helpers only do
> > bytewise copying anyways. And I think we've pretty much gotten rid of
> > all the raw attribute accesses.
> 
> What about stuff like xfrm_userpolicy_info? I suppose if *everything*
> is copied then it wouldn't matter.

You were saying?

[ 6400.609361] Kernel unaligned access at TPC[10258734] copy_to_user_state+0x54/0x9c [xfrm_user]
[ 6400.609498] Kernel unaligned access at TPC[10258734] copy_to_user_state+0x54/0x9c [xfrm_user]
[ 6400.667575] Kernel unaligned access at TPC[10258734] copy_to_user_state+0x54/0x9c [xfrm_user]
[ 6400.667707] Kernel unaligned access at TPC[10258734] copy_to_user_state+0x54/0x9c [xfrm_user]

This problem has existed for a long time.  In this specific case even
if you use memcpy() (in fact memcpy() is being used here) GCC sees the
types and says it can do aligned 64-bit loads and stores to do the
memcpy() inline.
