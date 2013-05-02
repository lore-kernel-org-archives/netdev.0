From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [GIT] Networking
Date: Thu, 2 May 2013 21:18:07 +0100
Message-ID: <1367525887.5106.140.camel@deadeye.wl.decadent.org.uk>
References: <20130502.041625.412316202038784117.davem@davemloft.net>
	 <20130502083619.GA22010@macbook.localnet> <87d2t9bvj1.fsf@nemi.mork.no>
	 <20130502.140125.697030413654996310.davem@davemloft.net>
	 <20866.46636.642215.768865@quad.stoffel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <bjorn@mork.no>,
	<kaber@trash.net>, <torvalds@linux-foundation.org>,
	<hayeswang@realtek.com>, <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: John Stoffel <john@stoffel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7079 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762086Ab3EBUSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 16:18:12 -0400
In-Reply-To: <20866.46636.642215.768865@quad.stoffel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-02 at 14:53 -0400, John Stoffel wrote:
> >>>>> "David" =3D=3D David Miller <davem@davemloft.net> writes:
>=20
> David> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> David> Date: Thu, 02 May 2013 11:06:42 +0200
>=20
> >> From d957cf339bf625869c39d852ac6733ef597ecef9 Mon Sep 17 00:00:00 =
2001
> >> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> >> Date: Thu, 2 May 2013 10:37:05 +0200
> >> Subject: [PATCH] net: vlan,ethtool: netdev_features_t is more than=
 32 bit
> >> MIME-Version: 1.0
> >> Content-Type: text/plain; charset=3DUTF-8
> >> Content-Transfer-Encoding: 8bit
> >>=20
> >> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
>=20
> David> Also applied and queued up for -stable.
>=20
> David> These changes show me that this special type isn't providing t=
ype
> David> safety in the way that we actually need it.
>=20
> David> Something like how we do the MM page table types would work be=
tter:
>=20
> David> typedef struct { u64 val; } netdev_features_t;
>=20
> David> #define __netdev_feature(X)	((netdev_features_t) { X } )
>=20
> David> and also with the appropriate set of accessors.
>=20
> David> Then you can't get it wrong without a compile error.
>=20
> Isn't part of the problem that you're exporting it into /sys in a
> binary format?
[...]

=46eatures are exported through SIOCETHTOOL, not sysfs (though they *us=
ed*
to be there).

The 'flags' attribue in sysfs is something different.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
