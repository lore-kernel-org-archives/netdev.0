From: "David S. Miller" <davem@davemloft.net>
Subject: Re: PROBLEM: OOPS in Linux 2.6.9, fib_release_info
Date: Tue, 30 Nov 2004 20:46:44 -0800
Message-ID: <20041130204644.4319f974.davem@davemloft.net>
References: <20041201011612.GA3423@kotelna.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261205AbULAEtk@vger.kernel.org>
To: Martin Lucina <mato@kotelna.sk>
In-Reply-To: <20041201011612.GA3423@kotelna.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Dec 2004 02:16:12 +0100
Martin Lucina <mato@kotelna.sk> wrote:

> I have found a reproducible OOPS in fib_release_info, in the 2.6.9 kernel.
> Tested on two different systems, one UP, one SMP, both i386, both w/
> CONFIG_PREEMPT=y, both Debian sarge, both w/ iproute2 version 20010824-13.1
> (Debian).

Already fixed in 2.6.10 by this patch.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/25 20:09:20-07:00 ehrhardt@mathematik.uni-ulm.de 
#   [IPV4]: Do not try to unhash null-netdev nexthops.
#   
#   Signed-off-by: Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/fib_semantics.c
#   2004/10/25 20:09:01-07:00 ehrhardt@mathematik.uni-ulm.de +2 -0
#   [IPV4]: Do not try to unhash null-netdev nexthops.
#   
#   Signed-off-by: Christian Ehrhardt <ehrhardt@mathematik.uni-ulm.de>
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
diff -Nru a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
--- a/net/ipv4/fib_semantics.c	2004-11-30 20:22:10 -08:00
+++ b/net/ipv4/fib_semantics.c	2004-11-30 20:22:10 -08:00
@@ -163,6 +163,8 @@
 		if (fi->fib_prefsrc)
 			hlist_del(&fi->fib_lhash);
 		change_nexthops(fi) {
+			if (!nh->nh_dev)
+				continue;
 			hlist_del(&nh->nh_hash);
 		} endfor_nexthops(fi)
 		fi->fib_dead = 1;
