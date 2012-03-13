From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Mon, 12 Mar 2012 22:54:35 -0700 (PDT)
Message-ID: <20120312.225435.1585479447873313061.davem@davemloft.net>
References: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55906 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759728Ab2CMFyk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 01:54:40 -0400
In-Reply-To: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 12 Mar 2012 22:12:21 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> See ffs(x) definition in arch/x86/include/asm/bitops.h
>=20
>   ffs - find first set bit in word
>=20
>   ffs(value) returns 0 if value is 0 or the position of the first
>   set bit if value is nonzero. The first (least significant) bit
>   is at position 1.
>=20
> On x86_64 ffs(x) is effectively:
>   Z :=3D -1
>   BSFL X, Z
>   return Z + 1
>=20
> Since we subtract one, we effectively end up with:
>   Z :=3D -1
>   BSFL X, Z
>   return Z
>=20
> This is certainly more readable than the open coded array that
> was there before, supports an easier change in the number of bands,
> and is probably faster to boot (no memory lookup).
>=20
> However, on other architectures ffs() might not be so pretty,
> hence use a clever arithmetic hack on other archs.
> Unfortunately it only support 3 bands.
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

It's about the same cost, the non-ffs() version, so I would just
use that for now.  Conditionalized code is such a pain in the butt.
