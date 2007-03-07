From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: [RFC] div64_64 support
Date: Wed, 07 Mar 2007 11:11:49 -0500
Message-ID: <45EEE445.4080806@redhat.com>
References: <20070223170527.4ca695b2@freekitty> <20070305155714.3abe1b5e@freekitty> <20070306133404.GA864@one.firstfloor.org> <200703061519.20346.dada1@cosmosbay.com> <20070306144529.GA2004@one.firstfloor.org> <84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de> <20070306102941.32471d57@freekitty> <20070306215349.hquin7d6pfy2n5d2@m.safari.iki.fi> <20070306222435.cbpv63ltximq6lrf@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sami Farin <7atbggg02@sneakemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56701 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965511AbXCGQft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 11:35:49 -0500
In-Reply-To: <20070306222435.cbpv63ltximq6lrf@m.safari.iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sami Farin wrote:
> On Tue, Mar 06, 2007 at 23:53:49 +0200, Sami Farin wrote:
> ...
>> And I found bug in gcc-4.1.2, it gave 0 for ncubic results
>> when doing 1000 loops test... gcc-4.0.3 works.
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

Can you post the difference in the generated code with that change?

