From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 9/11] PKT_SCHED: Cleanup cls_set_class
Date: Wed, 27 Oct 2004 11:42:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027094238.GM12289@postel.suug.ch>
References: <20041026222148.GA12289@postel.suug.ch> <20041026222813.GJ12289@postel.suug.ch> <1098867450.1813.37.camel@cyan.cph.tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <1098867450.1813.37.camel@cyan.cph.tpack.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> This locks once too many.
> (And it returns an *unsigned* long.)

Thanks. I wonder how this lock could get in there.


Remove bogus lock and make cls_set_class return unsigned long.

Signed-off-by: Thomas Graf <tgraf@suug.ch>


--- linux-2.6.10-rc1-bk1.orig/include/net/pkt_cls.h	2004-10-26 23:42:10.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/pkt_cls.h	2004-10-27 11:35:05.000000000 +0200
@@ -28,14 +28,12 @@
 	return old_cl;
 }
 
-static inline long
+static inline unsigned long
 cls_set_class(struct tcf_proto *tp, unsigned long *clp, 
 	unsigned long cl)
 {
 	unsigned long old_cl;
 	
-	qdisc_lock_tree(tp->q->dev);
-
 	tcf_tree_lock(tp);
 	old_cl = __cls_set_class(clp, cl);
 	tcf_tree_unlock(tp);
