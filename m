From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: MediaGX/GeodeGX1 requires X86_OOSTORE.
Date: Sat, 17 Feb 2007 10:07:20 -0500
Message-ID: <20070217150720.GK7582@csclub.uwaterloo.ca>
References: <20070216222728.GF7585@csclub.uwaterloo.ca> <20070216224824.GG7585@csclub.uwaterloo.ca> <20070217000019.GH7582@csclub.uwaterloo.ca> <20070217.231113.193678444.takada@mbf.nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: takada <takada@mbf.nifty.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:54980 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946772AbXBQPHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Feb 2007 10:07:20 -0500
Content-Disposition: inline
In-Reply-To: <20070217.231113.193678444.takada@mbf.nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 17, 2007 at 11:11:13PM +0900, takada wrote:
> is it mean what doesn't help with doesn't call set_cx86_reoder()?
> this function disable to reorder at 0x4000:0000 to 0xffff:ffff.
> does pcnet32 access at out of above range?

No it is accessing system memory by DMA to transfer frames.  Since the
system has 128MB ram, the addresses are probably all in the first 128MB
range.

I tried changing cyrix.c to explicitly set the serialize bit (0x8000 in
PCR0) rather than explcitly clearing it as is done now.  Didn't make a
difference.  I tried reversing the memory bypass setting, which also did
nothing.  Enabling CONFIG_X86_OOSTORE and recompiling however does make
a difference.

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

I did:
	depends on ((MWINCHIP3D || MWINCHIP2 || MWINCHIPC6) && MTRR) || MGEODEGX1
since I wasn't sure of the precedence in the Kconfig files.

--
Len Sorensen
