From: Sami Farin <7atbggg02@sneakemail.com>
Subject: Re: asm volatile [Was: [RFC] div64_64 support]
Date: Thu, 8 Mar 2007 20:23:57 +0200
Message-ID: <20070308182357.nnpvhqqj5qqk2vsx@m.safari.iki.fi>
References: <20070223170527.4ca695b2@freekitty> <20070305155714.3abe1b5e@freekitty> <20070306133404.GA864@one.firstfloor.org> <200703061519.20346.dada1@cosmosbay.com> <20070306144529.GA2004@one.firstfloor.org> <84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de> <20070306102941.32471d57@freekitty> <20070306215349.hquin7d6pfy2n5d2@m.safari.iki.fi> <20070306222435.cbpv63ltximq6lrf@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:38319 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933134AbXCHTdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 14:33:43 -0500
Received: from safari.iki.fi (80.223.106.128) by pne-smtpout3-sn1.fre.skanova.net (7.2.075)
        id 45AE1FD5002B9900 for netdev@vger.kernel.org; Thu, 8 Mar 2007 19:23:59 +0100
Content-Disposition: inline
In-Reply-To: <20070306222435.cbpv63ltximq6lrf@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2007 at 00:24:35 +0200, Sami Farin wrote:
> On Tue, Mar 06, 2007 at 23:53:49 +0200, Sami Farin wrote:
> ...
> > And I found bug in gcc-4.1.2, it gave 0 for ncubic results
> > when doing 1000 loops test... gcc-4.0.3 works.
> 
> Found it.
> 
> --- cbrt-test.c~	2007-03-07 00:20:54.735248105 +0200
> +++ cbrt-test.c	2007-03-07 00:21:03.964864343 +0200
> @@ -209,7 +209,7 @@
>  
>  	__asm__("bsrl %1,%0\n\t"
>  		"cmovzl %2,%0"
> -		: "=&r" (r) : "rm" (x), "rm" (-1));
> +		: "=&r" (r) : "rm" (x), "rm" (-1) : "memory");
>  	return r+1;
>  }
>  
> Now Linux 2.6 does not have "memory" in fls, maybe it causes
> some gcc funnies some people are seeing.

It also works without "memory" if I do "__asm__ volatile".

Why some functions have volatile and some have not in include/asm-*/*.h ?

-- 
