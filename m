From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: mac8390 - Sort out memory/MMIO accesses and casts
Date: Wed, 02 Jun 2010 11:21:30 -0700
Message-ID: <1275502890.23599.22.camel@Joe-Laptop.home>
References: <1275500180-32640-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	Finn Thain <fthain@telegraphics.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2561 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932628Ab0FBSVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 14:21:32 -0400
In-Reply-To: <1275500180-32640-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 19:36 +0200, Geert Uytterhoeven wrote:
> commit 5c7fffd0e3b57cb63f50bbd710868f012d67654f ("drivers/net/mac8390.c: Remove
> useless memcpy casting") removed too many casts, introducing the following
> warnings:
> 
> | drivers/net/mac8390.c:248: warning: passing argument 1 of '__builtin_memcpy' makes pointer from integer without a cast
> | drivers/net/mac8390.c:253: warning: passing argument 1 of 'word_memcpy_tocard' makes pointer from integer without a cast
> | drivers/net/mac8390.c:255: warning: passing argument 2 of 'word_memcpy_fromcard' makes pointer from integer without a cast
> 
> Instead of just readding the casts,
>   - move all casts inside word_memcpy_{to,from}card(),
>   - replace an incorrect memcpy() by memcpy_toio(),
>   - add memcmp_withio() as a wrapper around memcmp(),
>   - replace an incorrect memcpy_toio() by memcpy_fromio().
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Tested-by: Finn Thain <fthain@telegraphics.com.au>

Thanks Geert and Finn.

Apologies for not setting up a cross-compiler to fix this.

cheers, Joe

