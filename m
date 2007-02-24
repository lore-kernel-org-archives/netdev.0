From: Sami Farin <7atbggg02@sneakemail.com>
Subject: Re: [RFC] div64_64 support
Date: Sat, 24 Feb 2007 18:19:16 +0200
Message-ID: <20070224161916.GL3982@m.safari.iki.fi>
References: <20070223170527.4ca695b2@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn1.fre.skanova.net ([81.228.11.168]:63138 "EHLO
	pne-smtpout4-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932427AbXBXR2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 12:28:52 -0500
Received: from safari.iki.fi (80.223.106.128) by pne-smtpout4-sn1.fre.skanova.net (7.2.075)
        id 45C775BA00113FE5 for netdev@vger.kernel.org; Sat, 24 Feb 2007 17:19:19 +0100
Content-Disposition: inline
In-Reply-To: <20070223170527.4ca695b2@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 23, 2007 at 17:05:27 -0800, Stephen Hemminger wrote:
> Since there already two users of full 64 bit division in the kernel,
> and other places maybe hiding out as well. Add a full 64/64 bit divide.
> 
> Yes this expensive, but there are places where it is necessary.
> It is not clear if doing the scaling buys any advantage on 64 bit platforms,
> so for them a full divide is done.

Still does not work after these fixes... how came?

WARNING: "div64_64" [net/netfilter/xt_connbytes.ko] undefined!
WARNING: "div64_64" [net/ipv4/tcp_cubic.ko] undefined!

--- linux-2.6.19/include/asm-i386/div64.h.bak	2006-11-29 23:57:37.000000000 +0200
+++ linux-2.6.19/include/asm-i386/div64.h	2007-02-24 16:24:55.822529880 +0200
@@ -45,4 +45,7 @@ div_ll_X_l_rem(long long divs, long div,
 	return dum2;
 
 }
+
+extern uint64_t div64_64(uint64_t dividend, uint64_t divisor);
+
 #endif
--- linux-2.6.19/lib/div64.c.bak	2007-02-24 16:10:03.686084000 +0200
+++ linux-2.6.19/lib/div64.c	2007-02-24 17:01:11.224517353 +0200
@@ -80,4 +80,6 @@ uint64_t div64_64(uint64_t dividend, uin
 	return dividend;
 }
 
+EXPORT_SYMBOL(div64_64);
+
 #endif /* BITS_PER_LONG == 32 */

-- 
