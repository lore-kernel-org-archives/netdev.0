From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Fri, 26 Aug 2005 21:49:11 +0200
Message-ID: <17167.29239.469711.847951@robur.slu.se>
References: <20050815213855.GA17832@netnation.com>
	<43014E27.1070104@cosmosbay.com>
	<20050823190852.GA20794@netnation.com>
	<17163.32645.202453.145416@robur.slu.se>
	<20050824000158.GA8137@netnation.com>
	<20050825181111.GB14336@netnation.com>
	<20050825200543.GA6612@yakov.inr.ac.ru>
	<20050825212211.GA23384@netnation.com>
	<20050826115520.GA12351@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Simon Kirby <sim@netnation.com>, Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050826115520.GA12351@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

This thread seems familar :)

I think Simon uses UP and it could be idea to check if the RCU deferred 
deletion causes the problem. 

Simon it would be interesting to see if the patch below makes any 
difference given the assumption about UP was correct,

Cheers.
					--ro


diff --git a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -485,7 +485,11 @@ static struct file_operations rt_cpu_seq
 static __inline__ void rt_free(struct rtable *rt)
 {
 	multipath_remove(rt);
+#ifdef CONFIG_SMP
 	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
+#else
+	dst_free((struct dst_entry *)rt);
+#endif
 }
 
 static __inline__ void rt_drop(struct rtable *rt)
