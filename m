From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH -next] net: avoid inet dependency on aes crypto
Date: Mon, 22 Apr 2013 20:50:10 +0100
Message-ID: <1366660210.4016.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366637403-11212-1-git-send-email-fw@strlen.de>
	 <20130422.152531.1248159074404804010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <fw@strlen.de>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8924 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754814Ab3DVTuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 15:50:14 -0400
In-Reply-To: <20130422.152531.1248159074404804010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-22 at 15:25 -0400, David Miller wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 22 Apr 2013 15:30:03 +0200
> 
> > commit 798b2cbf9227b1bd7d37ae9af4d9c750e6f4de9c
> > (net: Add INET dependency on aes crypto for the sake of TCP fastopen.)
> > results in aes-asm module no longer being loaded when AES cipher is
> > requested, due to CRYPTO_AES=y.
> > 
> > However, there is no link-time dependency on aes. Drop dep and instead
> > set "default m" for aes crypto if inet is enabled.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> 
> This is terrible on so many levels.
> 
> If the assembler versions of the AES module can't be loaded properly
> when AES is built statically into the kernel, don't work around it,
> fix it instead.

On x86 the appropriate optimised aes implementation should still be
loaded based on an 'x86cpu' alias.  I don't know whether it will end up
being used.

It doesn't look like anything similar has been done for other
architectures yet, but that is probably the way to go.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
