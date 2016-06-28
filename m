From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Bridge: Fix ipv6 mc snooping if bridge has no ipv6
 address
Date: Tue, 28 Jun 2016 05:48:48 -0400 (EDT)
Message-ID: <20160628.054848.470650145752210386.davem@davemloft.net>
References: <1466764518-11358-1-git-send-email-daniel@dd-wrt.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stephen@networkplumber.org,
	linus.luessing@c0d3.blue
To: daniel@dd-wrt.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466764518-11358-1-git-send-email-daniel@dd-wrt.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Daniel Danzberger <daniel@dd-wrt.com>
Date: Fri, 24 Jun 2016 12:35:18 +0200

> The bridge is falsly dropping ipv6 mulitcast packets if there is:
>  1. No ipv6 address assigned on the brigde.
>  2. No external mld querier present.
>  3. The internal querier enabled.
>=20
> When the bridge fails to build mld queries, because it has no
> ipv6 address, it slilently returns, but keeps the local querier enabl=
ed.
> This specific case causes confusing packet loss.
>=20
> Ipv6 multicast snooping can only work if:
>  a) An external querier is present
>  OR
>  b) The bridge has an ipv6 address an is capable of sending own queri=
es
>=20
> Otherwise it has to forward/flood the ipv6 multicast traffic,
> because snooping cannot work.
>=20
> This patch fixes the issue by adding a flag to the bridge struct that
> indicates that there is currently no ipv6 address assinged to the bri=
dge
> and returns a false state for the local querier in
> __br_multicast_querier_exists().
>=20
> Special thanks to Linus L=FCssing.
>=20
> Signed-off-by: Daniel Danzberger <daniel@dd-wrt.com>

Applied.
