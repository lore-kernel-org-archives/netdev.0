From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP crashes when cycling loopback interface.
Date: Sat, 23 Oct 2004 15:48:56 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041023054856.GA19324@gondor.apana.org.au>
References: <20041023012018.GA15257@gondor.apana.org.au> <Xine.LNX.4.44.0410222322460.19110-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0410222322460.19110-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Oct 22, 2004 at 11:23:10PM -0400, James Morris wrote:
> 
> Did not seem to trip during a crash in 2.6.9-mm1

Oh well.  Please apply this patch and tell me whether packets_out
is postive or negative when it crashes.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

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

--dDRMvlgZJXvWKvBx--
