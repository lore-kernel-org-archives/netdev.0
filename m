From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 14:01:25 -0400 (EDT)
Message-ID: <20130502.140125.697030413654996310.davem@davemloft.net>
References: <20130502.041625.412316202038784117.davem@davemloft.net>
	<20130502083619.GA22010@macbook.localnet>
	<87d2t9bvj1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, torvalds@linux-foundation.org,
	hayeswang@realtek.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com
To: bjorn@mork.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d2t9bvj1.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Thu, 02 May 2013 11:06:42 +0200

> From d957cf339bf625869c39d852ac6733ef597ecef9 Mon Sep 17 00:00:00 200=
1
> From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn@mork.no>
> Date: Thu, 2 May 2013 10:37:05 +0200
> Subject: [PATCH] net: vlan,ethtool: netdev_features_t is more than 32=
 bit
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3DUTF-8
> Content-Transfer-Encoding: 8bit
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Also applied and queued up for -stable.

These changes show me that this special type isn't providing type
safety in the way that we actually need it.

Something like how we do the MM page table types would work better:

typedef struct { u64 val; } netdev_features_t;

#define __netdev_feature(X)	((netdev_features_t) { X } )

and also with the appropriate set of accessors.

Then you can't get it wrong without a compile error.

But this is net-next material of course.
