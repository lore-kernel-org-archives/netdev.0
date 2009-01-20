From: David Miller <davem@davemloft.net>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Mon, 19 Jan 2009 18:03:30 -0800 (PST)
Message-ID: <20090119.180330.255801668.davem@davemloft.net>
References: <20090115211403.3792.24995.stgit@speedy5>
	<20090119.170308.145804150.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39407
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752374AbZATCD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 21:03:28 -0500
In-Reply-To: <20090119.170308.145804150.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 19 Jan 2009 17:03:08 -0800 (PST)

> From: Divy Le Ray <divy@chelsio.com>
> Date: Thu, 15 Jan 2009 13:14:03 -0800
> 
> > cxgb3: Replace LRO with GRO
> > 
> > This patch makes cxgb3 invoke the GRO hooks instead of LRO.  As
> > GRO has a compatible external interface to LRO this is a very
> > straightforward replacement.
> > 
> > I've kept the ioctl controls for per-queue LRO switches.  However,
> > we should not encourage anyone to use these.
> > 
> > Because of that, I've also kept the skb construction code in
> > cxgb3.  Hopefully we can phase out those per-queue switches
> > and then kill this too.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > Acked-by: Divy Le Ray <divy@chelsio.com>
> 
> I've added this to my net-next-2.6 tree.
> 
> I'm confident that you will work out the performance issues
> with Herbert, else we'll simply revert this.

I had to add a fix due to some build bustage resulting from
this change.

drivers/scsi/cxgb3i/cxgb3i_ddp.h was depending upon the implicit
inclusion of linux/vmalloc.h coming from the inet_lro.h include
which is removed by this change.

In file included from drivers/scsi/cxgb3i/cxgb3i_ddp.c:24:
drivers/scsi/cxgb3i/cxgb3i_ddp.h: In function 'cxgb3i_alloc_big_mem':
drivers/scsi/cxgb3i/cxgb3i_ddp.h:148: error: implicit declaration of function 'vmalloc'
drivers/scsi/cxgb3i/cxgb3i_ddp.h:148: warning: assignment makes pointer from integer without a cast
drivers/scsi/cxgb3i/cxgb3i_ddp.h: In function 'cxgb3i_free_big_mem':
drivers/scsi/cxgb3i/cxgb3i_ddp.h:157: error: implicit declaration of function 'vfree'

I'll fix this up.
