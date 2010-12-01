From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] af_packet: use vmalloc_to_page() instead for the
 addresss returned by vmalloc()
Date: Wed, 01 Dec 2010 14:38:11 +0100
Message-ID: <1291210691.2856.740.camel@edumazet-laptop>
References: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com>
	 <1291126341.2904.82.camel@edumazet-laptop>
	 <20101130143720.GA6017@hmsreliant.think-freely.org>
	 <AANLkTim7SSRMkhc_eMz+Bk12kAwfG==j-dH4NOPu-uS2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50746 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558Ab0LANiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 08:38:17 -0500
Received: by wwa36 with SMTP id 36so7397206wwa.1
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 05:38:16 -0800 (PST)
In-Reply-To: <AANLkTim7SSRMkhc_eMz+Bk12kAwfG==j-dH4NOPu-uS2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 21:05 +0800, Changli Gao a =C3=
=A9crit :
> On Tue, Nov 30, 2010 at 10:37 PM, Neil Horman <nhorman@tuxdriver.com>=
 wrote:
> > Off the top of my head, I would think that pgv_to_page could be pro=
totyped such
> > that it could accept addr, offset and struct page ** arguments.  Th=
at way we can
> > track the current page that we're mapped to, lowering the number of=
 calls to
> > vmalloc_to_page, and we can still use an increment like we do above=
 (as long as
> > its wrapped in a subsequent call to pgv_to_page)
>=20
> I'll try to optimize pgv_to_page() after this patch series merged. I
> am planning to call vmalloc_to_page() previously, and cache its resul=
t
> in a per pgv array for future use. Thanks.
>=20
>=20

Hmm... fact is flush_dcache_page() is void on some arches.

Maybe the only thing to do is avoid pgv_to_page() calls if
ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE is 0

    The ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE symbol was introduced to avoi=
d
    pointless empty cache-thrashing loops on architectures for which
    flush_dcache_page() is a no-op.  Every architecture was provided wi=
th this
    flush pages on architectires where ARCH_IMPLEMENTS_FLUSH_DCACHE_PAG=
E is
    equal 1 or do nothing otherwise.



