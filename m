From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Broken? 2.6.6 + IP_ADD_SOURCE_MEMBERSHIP + SO_REUSEADDR
Date: Sat, 05 Jun 2004 02:14:11 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605.021411.55160771.yoshfuji@linux-ipv6.org>
References: <20040604155423.GA5656@muffin>
	<20040605.015544.102223977.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040605.015544.102223977.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040605.015544.102223977.yoshfuji@linux-ipv6.org> (at Sat, 05 Jun 2004 01:55:44 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> The following patch should fix the issue. Please try.

And, here's a variant for 2.4.

===== net/ipv4/udp.c 1.13 vs edited =====
--- 1.13/net/ipv4/udp.c	2004-02-22 06:12:49 +09:00
+++ edited/net/ipv4/udp.c	2004-06-05 01:56:50 +09:00
@@ -290,7 +290,7 @@
 		    ipv6_only_sock(s)					||
 		    (s->bound_dev_if && s->bound_dev_if != dif))
 			continue;
-		if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, dif))
+		if (!ip_mc_sf_allow(s, loc_addr, rmt_addr, dif))
 			continue;
 		break;
   	}

-- yoshfuji @ time to sleep...
