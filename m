From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8842: Fix TX cache flush issue
Date: Sun, 28 Nov 2010 10:38:14 -0800 (PST)
Message-ID: <20101128.103814.193728413.davem@davemloft.net>
References: <1290430257.13971.7.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ferringb@gmail.com
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54740
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753795Ab0K1Shs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Nov 2010 13:37:48 -0500
In-Reply-To: <1290430257.13971.7.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Mon, 22 Nov 2010 13:50:57 +0100

> This patch fixes a cache sync issue found in MeeGo 1.1.
>=20
> It was found that bytes after the first 64 of the TX buffer was not
> flushed from the cache correctly.
>=20
> The patch switches out kmalloc/dma_map_single/dma_sync_single_for_dev=
ice
> to dma_alloc_coherent.
>=20
> Signed-off-by: Richard R=F6jfors <richard.rojfors@pelagicore.com>

Why is dma_sync_single_*() not working properly?

Maybe the length arguments are not correct?  Maybe the cache flush
implementation accidently misses the last cache line when the buffer
length ends in the middle of a cache line.

Did you even check to see what the actual cause of the problem is?

I'm not applying this patch, not enough justification or explanation
in the commit message exists yet.  For all we know there could be
a bug elsewhere, and that would effect other drivers too not just
ks8842.

