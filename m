From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Broken? 2.6.6 + IP_ADD_SOURCE_MEMBERSHIP + SO_REUSEADDR
Date: Sat, 05 Jun 2004 01:55:44 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605.015544.102223977.yoshfuji@linux-ipv6.org>
References: <20040604155423.GA5656@muffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: terpstra@gkec.tu-darmstadt.de
In-Reply-To: <20040604155423.GA5656@muffin>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040604155423.GA5656@muffin> (at Fri, 4 Jun 2004 17:54:23 +0200), "Wesley W. Terpstra" <terpstra@gkec.tu-darmstadt.de> says:

> If I launch the same program twice with different senders, the first program
> ceases to receive multicast packets. (Neither from its own sender, nor the
> second program's sender) The second program receives packets from its
> designated sender only (as expected).
:
> If both programs specify the same sender, then both programs receive the
> message (as expected).

Thanks for the report.
The following patch should fix the issue. Please try.
Thanks again.

===== net/ipv4/udp.c 1.60 vs edited =====
--- 1.60/net/ipv4/udp.c	2004-05-31 03:57:26 +09:00
+++ edited/net/ipv4/udp.c	2004-06-05 01:47:07 +09:00
@@ -294,7 +294,7 @@
 		    ipv6_only_sock(s)					||
 		    (s->sk_bound_dev_if && s->sk_bound_dev_if != dif))
 			continue;
-		if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, dif))
+		if (!ip_mc_sf_allow(s, loc_addr, rmt_addr, dif))
 			continue;
 		goto found;
   	}

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
