From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Mon, 19 Feb 2007 09:55:14 -0500
Message-ID: <20070219145514.GO7582@csclub.uwaterloo.ca>
References: <20070216222728.GF7585@csclub.uwaterloo.ca> <20070216224824.GG7585@csclub.uwaterloo.ca> <20070217000019.GH7582@csclub.uwaterloo.ca> <20070217.231113.193678444.takada@mbf.nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: takada <takada@mbf.nifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:53916 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932318AbXBSOzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 09:55:15 -0500
Content-Disposition: inline
In-Reply-To: <20070217.231113.193678444.takada@mbf.nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 17, 2007 at 11:11:13PM +0900, takada wrote:
> is it mean what doesn't help with doesn't call set_cx86_reoder()?
> this function disable to reorder at 0x4000:0000 to 0xffff:ffff.
> does pcnet32 access at out of above range?
> 
> --- arch/i386/Kconfig.cpu~	2007-02-05 03:44:54.000000000 +0900
> +++ arch/i386/Kconfig.cpu	2007-02-17 21:25:52.000000000 +0900
> @@ -322,7 +322,7 @@ config X86_USE_3DNOW
>  
>  config X86_OOSTORE
>  	bool
> -	depends on (MWINCHIP3D || MWINCHIP2 || MWINCHIPC6) && MTRR
> +	depends on (MWINCHIP3D || MWINCHIP2 || MWINCHIPC6) && MTRR || MGEODEGX1
>  	default y
>  
>  config X86_TSC

Well it turns out that enabling OOSTORE doesn't elliminate the problem,
but it does make it go from occouring within seconds to occouring within
many hours.  I am off to investigate some more.

Does anyone know if there is any way to flush a cache line of the cpu to
force rereading system memory for a given address or address range?

--
Len Sorensen
