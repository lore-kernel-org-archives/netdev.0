From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.5.70 kernel BUG at net/xfrm/xfrm_policy.c:185!
Date: Thu, 29 May 2003 14:58:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.145821.38706415.davem@redhat.com>
References: <1054236655.596.37.camel@simulacron>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: aj@dungeon.inka.de
In-Reply-To: <1054236655.596.37.camel@simulacron>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andreas Jellinghaus <aj@dungeon.inka.de>
   Date: 29 May 2003 21:30:55 +0200

   kernel: ------------[ cut here ]------------
   kernel: kernel BUG at net/xfrm/xfrm_policy.c:185!
   kernel: invalid operand: 0000 [#2]

You need to make sure you have Herbert's flow cache refcount
fix applied.

In general, try to run with the current -bk 2.5.x sources
as we fix bugs on almost a daily basis.  I personally consider
2.5.70 as released to be an ancient dinosaur already :-)

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1229.1.176 -> 1.1229.1.177
#	     net/core/flow.c	1.2     -> 1.3    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/05/27	herbert@gondor.apana.org.au	1.1229.1.177
# [NET]: Missing refcount bump in flow cache.
# --------------------------------------------
#
diff -Nru a/net/core/flow.c b/net/core/flow.c
--- a/net/core/flow.c	Thu May 29 14:57:31 2003
+++ b/net/core/flow.c	Thu May 29 14:57:31 2003
@@ -199,6 +199,8 @@
 				fle->genid = atomic_read(&flow_cache_genid);
 				fle->object = obj;
 				fle->object_ref = obj_ref;
+				if (obj)
+					atomic_inc(fle->object_ref);
 
 				flow_count(cpu)++;
 			}
