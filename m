From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP crashes when cycling loopback interface.
Date: Sat, 9 Oct 2004 16:53:21 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041009065320.GA28738@gondor.apana.org.au>
References: <E1CFVXD-0007iJ-00@gondolin.me.apana.org.au> <Xine.LNX.4.44.0410071234460.4571-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0410071234460.4571-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Oct 07, 2004 at 12:46:25PM -0400, James Morris wrote:
> 
> Two runs with the following crashes:
> 
> KERNEL: assertion (!skb_queue_empty(&sk->sk_write_queue)) failed at net/ipv4/tcp_timer.c (322)

Right so it didn't trigger the paths I was looking at.

Unfortunately I can't reproduce this crash at all by doing the ifdown/ifup
loop.  However I'm testing Linus's tree as opposed to mm.  Can you please
try that to see if it's something in mm?

If you can get it with Linus's tree, please apply this patch so that we
know a bit more about what we're looking for.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=q

===== net/ipv4/tcp_timer.c 1.24 vs edited =====
--- 1.24/net/ipv4/tcp_timer.c	2004-09-08 02:18:04 +10:00
+++ edited/net/ipv4/tcp_timer.c	2004-10-09 16:51:20 +10:00
@@ -319,6 +319,9 @@
 	if (!tcp_get_pcount(&tp->packets_out))
 		goto out;
 
+	if (skb_queue_empty(&sk->sk_write_queue))
+		printk(KERN_DEBUG "TCP: empty write queue packets_out = %d",
+		       tcp_get_pcount(&tp->packets_out));
 	BUG_TRAP(!skb_queue_empty(&sk->sk_write_queue));
 
 	if (!tp->snd_wnd && !sock_flag(sk, SOCK_DEAD) &&

--BOKacYhQ+x31HxR3--
