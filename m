From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] macvlan: export macvlan mode through netlink
Date: Wed, 18 Nov 2009 07:48:52 +0100
Message-ID: <4B0398D4.8030904@gmail.com>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <1258497551-25959-4-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42596 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbZKRGtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 01:49:12 -0500
In-Reply-To: <1258497551-25959-4-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann a =E9crit :
> In order to support all three modes of macvlan at
> runtime, extend the existing netlink protocol
> to allow choosing the mode per macvlan slave
> interface.
>=20
> This depends on a matching patch to iproute2
> in order to become accessible in user land.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/macvlan.c   |   67 +++++++++++++++++++++++++++++++++++++=
++++-----
>  include/linux/if_link.h |   15 ++++++++++
>  2 files changed, 74 insertions(+), 8 deletions(-)
>=20
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index fa8b568..731017e 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -33,12 +33,6 @@
> =20
>  #define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
> =20
> -enum macvlan_type {
> -	MACVLAN_PRIVATE		=3D 1,
> -	MACVLAN_VEPA		=3D 2,
> -	MACVLAN_BRIDGE		=3D 4,
> -};

I realize you defined MACVLAN_PRIVATE in patch 2, but used MACVLAN_MODE=
_PRIVATE,
so patch 2 is not compilable and breaks bisection ?


> +
> +enum ifla_macvlan_mode {
> +	MACVLAN_MODE_PRIVATE =3D 1, /* don't talk to other macvlans */
> +	MACVLAN_MODE_VEPA    =3D 2, /* talk to other ports through ext brid=
ge */
> +	MACVLAN_MODE_BRIDGE  =3D 4, /* talk to bridge ports directly */
> +};
