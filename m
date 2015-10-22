From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: CONFIG_XPS depends on L1_CACHE_BYTES being greater than
 sizeof(struct xps_map)
Date: Thu, 22 Oct 2015 14:50:15 -0700
Message-ID: <1445550615.22974.128.camel@edumazet-glaptop2.roam.corp.google.com>
References: <42430464-867C-4E0B-8E95-C6CDB6D8A0B2@bell.net>
	 <32A3BF6F-B243-4AD4-9AE9-A5F9DAE0270A@bell.net>
	 <B8E85737-5ECD-4CBE-8730-886B098C5FA4@bell.net>
	 <trinity-eda7d55d-7234-4b29-a15c-955f8ba0c95e-1445513884942@3capp-gmx-bs32>
	 <trinity-8980ad10-b889-45cf-8f37-a33ba9cf99ef-1445514797080@3capp-gmx-bs32>
	 <1445524549.2207.1.camel@HansenPartnership.com> <5628F868.3040105@bell.net>
	 <5629404B.8090805@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-parisc List <linux-parisc@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	John David Anglin <dave.anglin@bell.net>
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34181 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbbJVVuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 17:50:18 -0400
In-Reply-To: <5629404B.8090805@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-22 at 22:00 +0200, Helge Deller wrote:
> Hi Tom & David,
>=20
> I've queued-up a patch for the parisc architecture which reduces L1_C=
ACHE_BYTES from 32 to 16:
>   https://patchwork.kernel.org/patch/7399291/
>=20
> But this change will break the kernel build like this:
>=20
> In file included from net/core/dev.c:92:0:
> net/core/dev.c: In function =E2=80=98expand_xps_map=E2=80=99:
> include/linux/netdevice.h:721:27: warning: overflow in implicit const=
ant conversion [-Woverflow]
>    #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map=
)) \
> net/core/dev.c:1972:18: note: in expansion of macro =E2=80=98XPS_MIN_=
MAP_ALLOC=E2=80=99
>    int alloc_len =3D XPS_MIN_MAP_ALLOC;
>=20
> Do you see an easy way to fix this ?


Using L2_CACHE_BYTES would be better, but it unfortunately does not
exist.
