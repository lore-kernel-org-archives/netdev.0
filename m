From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH,RFC] [NET] ALIGN
Date: Tue, 10 Feb 2004 13:05:43 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040210.130543.130923643.yoshfuji@linux-ipv6.org>
References: <20040209.134528.28683257.yoshfuji@linux-ipv6.org>
	<20040209112007.08023ba6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040209112007.08023ba6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040209112007.08023ba6.davem@redhat.com> (at Mon, 9 Feb 2004 11:20:07 -0800), "David S. Miller" <davem@redhat.com> says:

> > BTW, 
> >  1. do we really need this ALIGN?
> >  2. should 16 be BYTES_PER_WORD (in mm/slab.c)?
:
> I think this is complete nonsense, and that the alignment is not
> necessary.  I can't even come up with a performance reason as SLAB
> is going to align things to hw cache line size anyways.

Agreed.

> Else let's just remove this bogus 16 byte alignment in the
> kmem_cache_create() call.

Let's kill it. It is very likely safe.

===== net/core/neighbour.c 1.24 vs edited =====
--- 1.24/net/core/neighbour.c	Tue Jan 20 14:31:23 2004
+++ edited/net/core/neighbour.c	Tue Feb 10 13:01:15 2004
@@ -1164,8 +1164,7 @@
 
 	if (!tbl->kmem_cachep)
 		tbl->kmem_cachep = kmem_cache_create(tbl->id,
-						     (tbl->entry_size +
-						      15) & ~15,
+						     tbl->entry_size,
 						     0, SLAB_HWCACHE_ALIGN,
 						     NULL, NULL);
 	tbl->lock	       = RW_LOCK_UNLOCKED;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
