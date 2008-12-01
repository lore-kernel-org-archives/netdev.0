From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 4/5] crypto: allow allocation of percpu crypto
 transforms
Date: Mon, 01 Dec 2008 04:25:02 -0800 (PST)
Message-ID: <20081201.042502.223043756.davem@davemloft.net>
References: <20081201071614.GP476@secunet.com>
	<20081201071943.GT476@secunet.com>
	<20081201113828.GA20961@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59079
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751530AbYLAMZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 07:25:03 -0500
In-Reply-To: <20081201113828.GA20961@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 1 Dec 2008 19:38:28 +0800

> On Mon, Dec 01, 2008 at 08:19:43AM +0100, Steffen Klassert wrote:
> > From: Steffen Klassert <steffen.klassert@secunet.com>
> > 
> > This patch adds functions to alloc/free crypto transforms
> > as percpu data.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> I'd prefer to just have the user call crypto_alloc_tfm for each
> CPU.  This is the slow path after all so we don't need to optimise
> it that much.

I somewhat disagree.

If you make this num_cpus expensive, I can nearly guarentee you this
will show up in the profiles for the workloads I was using to test the
control path optimizations with all the dynamic hash tables and
streamlined lookups.

Some cell phones networks, I am to understand, can allocate 6 SAs when
they come onto the network, perhaps never use them, then go away.
Multiply that by the number of cell phones using a network in a busy
downtown area of a city and it could be very interesting.

If, in those changes, I was removing atomics to make rule insert and
delete faster, making more TFM allocs happen might be a big no-no :)
