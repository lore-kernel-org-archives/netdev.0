From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: UDP counter doesn't increase
Date: Thu, 19 Feb 2004 11:25:57 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219.112557.102901782.yoshfuji@linux-ipv6.org>
References: <20040219110035.2e1c15b4%hibi665@oki.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, hibi665@oki.com
In-Reply-To: <20040219110035.2e1c15b4%hibi665@oki.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040219110035.2e1c15b4%hibi665@oki.com> (at Thu, 19 Feb 2004 11:00:35 +0900), Takashi Hibi <hibi665@oki.com> says:

> UdpInDatagram in /proc/net/snmp6 doen't increase when IPv6 multicast 
> UDP packets are received.
> sock_queue_rcv_skb() is called directly in udpv6_mcast_deliver. I think that
> udpv6_queue_rcv_skb() should be called instead of sock_queue_rcv_skb()
> as IPv4.

Okay, here's the patch.

===== net/ipv6/udp.c 1.58 vs edited =====
--- 1.58/net/ipv6/udp.c	Thu Jan 29 09:06:25 2004
+++ edited/net/ipv6/udp.c	Thu Feb 19 11:22:46 2004
@@ -591,12 +591,12 @@
 			if (!buff)
 				continue;
 		}
-		if (sock_queue_rcv_skb(sk2, buff) >= 0)
+		if (udpv6_queue_rcv_skb(sk2, buff) >= 0)
 			buff = NULL;
 	}
 	if (buff)
 		kfree_skb(buff);
-	if (sock_queue_rcv_skb(sk, skb) < 0) {
+	if (udpv6_queue_rcv_skb(sk, skb) < 0) {
 free_skb:
 		kfree_skb(skb);
 	}

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
