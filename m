From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2.6] [IPV6] SIT: dst leakage in error path.
Date: Sat, 02 Oct 2004 19:31:38 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041002.193138.94763422.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

We failed to put rt in error path.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv6/sit.c 1.41 vs edited =====
--- 1.41/net/ipv6/sit.c	2004-09-17 05:10:00 +09:00
+++ edited/net/ipv6/sit.c	2004-10-02 19:24:05 +09:00
@@ -487,6 +487,7 @@
 		}
 	}
 	if (rt->rt_type != RTN_UNICAST) {
+		ip_rt_put(rt);
 		tunnel->stat.tx_carrier_errors++;
 		goto tx_error_icmp;
 	}

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
