From: John Heffner <jheffner@psc.edu>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Tue, 28 Sep 2004 23:27:21 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.NEB.4.33.0409282323220.27103-100000@dexter.psc.edu>
References: <20040928223344.GC2975@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040928223344.GC2975@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004, Andi Kleen wrote:

> I'm afraid I must report it's still not completely solved for me yet.
> 10s netperf with TSO on with your patches gives now ~10MB/s less than
> with TSO off (57 vs 67). It's better than before, but not really
> fixed yet.
>
> Looking at my tcpdumps and comparing TSO on/off I see a quite
> strange effect. It only acks on every ~25th packet with TSO off
> but every ~16th packet with TSO on.
>
> Receiver is a 2.6.5 kernel, it's weird that it violates the
> ack every two MSS rule.

Does this help?

===== net/ipv4/tcp_input.c 1.73 vs edited =====
--- 1.73/net/ipv4/tcp_input.c	2004-09-12 20:30:58 -04:00
+++ edited/net/ipv4/tcp_input.c	2004-09-28 23:23:40 -04:00
@@ -3936,7 +4048,7 @@
 	     /* ... and right edge of window advances far enough.
 	      * (tcp_recvmsg() will send ACK otherwise). Or...
 	      */
-	     && __tcp_select_window(sk) >= tp->rcv_wnd) ||
+	    /* && __tcp_select_window(sk) >= tp->rcv_wnd */) ||
 	    /* We ACK each frame or... */
 	    tcp_in_quickack_mode(tp) ||
 	    /* We have out of order data. */
