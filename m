From: Adrian Bunk <bunk@stusta.de>
Subject: [patch] 2.4.28-rc3: neigh_for_each must be EXPORT_SYMBOL'ed
Date: Sat, 13 Nov 2004 21:07:35 +0100
Message-ID: <20041113200735.GD2249@stusta.de>
References: <20041112180052.GE23215@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	patrick@tykepenguin.com, linux-decnet-user@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261162AbUKMUIV@vger.kernel.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
	Harald Welte <laforge@gnumonks.org>,
	"David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041112180052.GE23215@logos.cnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm getting the following error:

<--  snip  -->

depmod: *** Unresolved symbols in /lib/modules/2.4.28-rc3/kernel/net/decnet/decnet.o
depmod:         neigh_for_each

<--  snip  -->


This was caused by Harald's backport of the neighbour scalability fixes 
from 2.6 .


neigh_for_each must be EXPORT_SYMBOL'ed (as it is in 2.6):


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.4.28-rc3-modular/net/core/Makefile.old	2004-11-13 19:40:36.000000000 +0100
+++ linux-2.4.28-rc3-modular/net/core/Makefile	2004-11-13 19:40:50.000000000 +0100
@@ -9,7 +9,7 @@
 
 O_TARGET := core.o
 
-export-objs := netfilter.o profile.o ethtool.o
+export-objs := netfilter.o profile.o ethtool.o neighbour.o
 
 obj-y := sock.o skbuff.o iovec.o datagram.o scm.o
 
--- linux-2.4.28-rc3-modular/net/core/neighbour.c.old	2004-11-13 19:35:26.000000000 +0100
+++ linux-2.4.28-rc3-modular/net/core/neighbour.c	2004-11-13 19:35:59.000000000 +0100
@@ -1569,6 +1569,7 @@
 	}
 	read_unlock_bh(&tbl->lock);
 }
+EXPORT_SYMBOL(neigh_for_each);
 
 /* The tbl->lock must be held as a writer and BH disabled. */
 void __neigh_for_each_release(struct neigh_table *tbl,
