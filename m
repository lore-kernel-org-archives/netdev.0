From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: bugs in net/ipv6/mcast.c (fwd)
Date: Mon, 27 Oct 2003 11:07:10 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031027.110710.54972254.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0310252226470.12162-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, niteowl@austin.rr.com, pekkas@netcore.fi,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <Pine.LNX.4.44.0310252226470.12162-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0310252226470.12162-100000@netcore.fi> (at Sat, 25 Oct 2003 22:27:27 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> Probably fixed already, but just in case...

Not yet in the bk tree.

> Hi.  In the latest linux-2.6.0-test8 source there are 2 bugs in 
> net/ipv6/mcast.c
> In function inet6_mc_check() the if statements on lines 607 and 609 have
> extra semicolons that will cause the code to fail.
> 
>                 if (mc->sfmode == MCAST_INCLUDE && i >= psl->sl_count);
>                         rv = 0;
>                 if (mc->sfmode == MCAST_EXCLUDE && i < psl->sl_count);
>                         rv = 0;

Exactly. Patch follows.

===== net/ipv6/mcast.c 1.39 vs edited =====
--- 1.39/net/ipv6/mcast.c	Fri Oct 17 17:05:20 2003
+++ edited/net/ipv6/mcast.c	Mon Oct 27 11:01:27 2003
@@ -604,9 +604,9 @@
 			if (ipv6_addr_cmp(&psl->sl_addr[i], src_addr) == 0)
 				break;
 		}
-		if (mc->sfmode == MCAST_INCLUDE && i >= psl->sl_count);
+		if (mc->sfmode == MCAST_INCLUDE && i >= psl->sl_count)
 			rv = 0;
-		if (mc->sfmode == MCAST_EXCLUDE && i < psl->sl_count);
+		if (mc->sfmode == MCAST_EXCLUDE && i < psl->sl_count)
 			rv = 0;
 	}
 	read_unlock(&ipv6_sk_mc_lock);


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
