From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: Bug in Linux 2.5.74 IPv6 routing
Date: Thu, 10 Jul 2003 03:44:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710.034425.55677522.yoshfuji@linux-ipv6.org>
References: <20030709195237.A8550@horus.imag.fr>
	<20030710.033117.93244305.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: Jean-Luc.Richier@imag.fr, pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, jmorris@intercode.com.au
In-Reply-To: <20030710.033117.93244305.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030710.033117.93244305.yoshfuji@linux-ipv6.org> (at Thu, 10 Jul 2003 03:31:17 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> Ok, let's use this one.

Please apply this patch.

D: Fix ipv6_addr_prefix() for prefixlen != 0 (mod 8).
D: Patch from Jean-Luc RICHIER <Jean-Luc.Richier@Imag.Fr>.

--- linux-2.5.74/include/net/ipv6.h.DIST	2003-07-02 22:53:44.000000000 +0200
+++ linux-2.5.74/include/net/ipv6.h	2003-07-09 18:51:25.000000000 +0200
@@ -276,8 +276,10 @@
 	    b = plen & 0x7;
 
 	memcpy(pfx->s6_addr, addr, o);
-	if (b != 0)
+	if (b != 0) {
 		pfx->s6_addr[o] = addr->s6_addr[o] & (0xff00 >> b);
+		o++;
+	}
 	if (o < 16)
 		memset(pfx->s6_addr + o, 0, 16 - o);
 }

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
