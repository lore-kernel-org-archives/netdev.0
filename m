From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 02:26:43 -0700 (PDT)
Message-ID: <20071031.022643.118035583.davem@davemloft.net>
References: <20071031074621.GB5059@kernel.dk>
	<20071031.005802.204286555.davem@davemloft.net>
	<20071031081428.GF5059@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	rusty@rustcorp.com.au
To: jens.axboe@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37584
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754045AbXJaJ0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 05:26:44 -0400
In-Reply-To: <20071031081428.GF5059@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jens Axboe <jens.axboe@oracle.com>
Date: Wed, 31 Oct 2007 09:14:28 +0100

> Subject: [PATCH] [SG] Get rid of __sg_mark_end()
> 
> sg_mark_end() overwrites the page_link information, but all users want
> __sg_mark_end() behaviour where we just set the end bit. That is the most
> natural way to use the sg list, since you'll fill it in and then mark the
> end point.
> 
> So change sg_mark_end() to only set the termination bit. Add a sg_magic
> debug check as well, and clear a chain pointer if it is set.
> 
> Signed-off-by: Jens Axboe <jens.axboe@oracle.com>

It doesn't build.  I suspect there is something else in your tree
that is necessary for this patch to work on it's own.

davem@sunset:~/src/GIT/net-2.6$ patch -p1 <diff
patching file block/ll_rw_blk.c
patching file drivers/scsi/scsi_lib.c
patching file include/linux/scatterlist.h
Hunk #2 succeeded at 242 (offset 22 lines).
patching file net/core/skbuff.c
patching file net/ipv4/tcp_ipv4.c
patching file net/ipv6/tcp_ipv6.c
patching file net/rxrpc/rxkad.c
patching file net/sunrpc/auth_gss/gss_krb5_crypto.c
 ...
  CC      init/main.o
In file included from include/asm/dma-mapping.h:4,
                 from include/linux/dma-mapping.h:52,
                 from include/asm/sbus.h:9,
                 from include/asm/dma.h:14,
                 from include/linux/bootmem.h:8,
                 from init/main.c:26:
include/linux/scatterlist.h: In function 'sg_init_one':
include/linux/scatterlist.h:228: error: too many arguments to function 'sg_mark_end'
make[1]: *** [init/main.o] Error 1
make: *** [init] Error 2
