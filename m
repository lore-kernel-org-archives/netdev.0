From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP crashes when cycling loopback interface.
Date: Sat, 23 Oct 2004 11:20:18 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041023012018.GA15257@gondor.apana.org.au>
References: <E1CFVXD-0007iJ-00@gondolin.me.apana.org.au> <Xine.LNX.4.44.0410071234460.4571-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0410071234460.4571-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Oct 07, 2004 at 12:46:25PM -0400, James Morris wrote:
> 
> Two runs with the following crashes:
> 
> KERNEL: assertion (!skb_queue_empty(&sk->sk_write_queue)) failed at net/ipv4/tcp_timer.c (322)

James, are you still getting this crash?

If so can you please apply this patch and see if it trips? If it
does then your problem has been found and fixed.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp_output.c 1.68 vs edited =====
--- 1.68/net/ipv4/tcp_output.c	2004-10-20 15:13:52 +10:00
+++ edited/net/ipv4/tcp_output.c	2004-10-23 11:19:21 +10:00
@@ -1038,6 +1038,7 @@
 			tp->mss_cache = tp->mss_cache_std;
 		}
 
+		BUG_TRAP(tcp_skb_pcount(skb) <= 1);
 		if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
 			return -ENOMEM;
 	}

--bp/iNruPH9dso1Pn--
