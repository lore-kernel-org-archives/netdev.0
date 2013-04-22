From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: avoid inet dependency on aes crypto
Date: Mon, 22 Apr 2013 15:25:31 -0400 (EDT)
Message-ID: <20130422.152531.1248159074404804010.davem@davemloft.net>
References: <1366637403-11212-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754756Ab3DVTZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 15:25:32 -0400
In-Reply-To: <1366637403-11212-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 22 Apr 2013 15:30:03 +0200

> commit 798b2cbf9227b1bd7d37ae9af4d9c750e6f4de9c
> (net: Add INET dependency on aes crypto for the sake of TCP fastopen.)
> results in aes-asm module no longer being loaded when AES cipher is
> requested, due to CRYPTO_AES=y.
> 
> However, there is no link-time dependency on aes. Drop dep and instead
> set "default m" for aes crypto if inet is enabled.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

This is terrible on so many levels.

If the assembler versions of the AES module can't be loaded properly
when AES is built statically into the kernel, don't work around it,
fix it instead.
