From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@wide.ad.jp>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Thu, 10 Oct 2002 04:23:33 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010.042333.122713397.yoshfuji@wide.ad.jp>
References: <Pine.LNX.4.44.0210092015540.17906-100000@netcore.fi>
	<200210091903.XAA20130@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.FI, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200210091903.XAA20130@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200210091903.XAA20130@sex.inr.ac.ru> (at Wed, 9 Oct 2002 23:03:29 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> > Personally I think the interfaces should be configured with a /64 but 
> > there should be a discard route for the whole /10.
> 
> I agressively agree. :-)

How about this (against 2.4.19 / 2.4.20-pre10)?

Index: net/ipv6/addrconf.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux24/net/ipv6/addrconf.c,v
retrieving revision 1.1.1.1.20.1
diff -u -r1.1.1.1.20.1 addrconf.c
--- net/ipv6/addrconf.c	2002/09/27 17:17:06	1.1.1.1.20.1
+++ net/ipv6/addrconf.c	2002/10/09 18:18:34
@@ -783,6 +783,7 @@
 	struct in6_addr addr;
 
 	ipv6_addr_set(&addr,  __constant_htonl(0xFE800000), 0, 0, 0);
+	addrconf_prefix_route(&addr, 10, dev, 0, RTF_ADDRCONF|RTF_REJECT);
 	addrconf_prefix_route(&addr, 64, dev, 0, RTF_ADDRCONF);
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
