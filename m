From: Nancy Milliner <njm@us.ibm.com>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Sun, 16 Jan 2005 17:03:37 -0600
Message-ID: <41EAF2C9.5010201@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

I've been running SPECweb99 with this patch all weekend and have not 
been able to produce any kernel assertions at all.  I'm currently 
running RH kernel 2.6.9-5.EL.root and have been able to reproduce at 
will when setting /proc/net/ipv4/tcp_tso_win_divisor to 1, 2 or 4.

Let me know when you have something else ready to test.

===== net/ipv4/tcp.c 1.88 vs edited =====
--- 1.88/net/ipv4/tcp.c	2005-01-06 15:13:39 -08:00
+++ edited/net/ipv4/tcp.c	2005-01-13 19:44:36 -08:00
@@ -664,7 +664,7 @@
  			if (!sk_stream_memory_free(sk))
  				goto wait_for_sndbuf;

-			skb = sk_stream_alloc_pskb(sk, 0, tp->mss_cache,
+			skb = sk_stream_alloc_pskb(sk, 0, 0,
  						   sk->sk_allocation);
  			if (!skb)
  				goto wait_for_memory;
@@ -689,6 +689,9 @@

  		skb->len += copy;
  		skb->data_len += copy;
+		skb->truesize += copy;
+		sk->sk_wmem_queued += copy;
+		sk->sk_forward_alloc -= copy;
  		skb->ip_summed = CHECKSUM_HW;
  		tp->write_seq += copy;
  		TCP_SKB_CB(skb)->end_seq += copy;
