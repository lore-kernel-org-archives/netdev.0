From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: md5 signature check scaling
Date: Wed, 27 Oct 2010 15:00:05 +0200
Message-ID: <1288184405.2709.108.camel@edumazet-laptop>
References: <AANLkTi=U1smX6XXDMyBTicyqbUU5V-t56jmH7qtX2XW5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	William.Allen.Simpson@gmail.com,
	Andreas Petlund <apetlund@simula.no>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Gilad Ben-Yossef <gilad@codefidence.com>,
	Yony Amit <yony@comsleep.com>, Zhu Yi <yi.zhu@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Dmitry Popov <dp@highloadlab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=U1smX6XXDMyBTicyqbUU5V-t56jmH7qtX2XW5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 27 octobre 2010 =C3=A0 16:52 +0400, Dmitry Popov a =C3=A9cr=
it :
> From: Dmitry Popov <dp@highloadlab.com>
>=20
> TCP MD5 signature checking without socket lock.
>=20
> Each tcp_sock has 2 RCU-protected arrays (tcp[46]_md5sig_info) of
> tcp[46]_md5sig_key address-key pairs.
> Each key (tcp_md5sig_key) has kref struct so that there is no need to
> lock the whole array to work with one key.
>=20
> MD5 functions were rewritten according to above statement and hash
> check (tcp_v4_inbound_md5_hash) was moved before socket lock.
>=20
> Signed-off-by: Dmitry Popov <dp@highloadlab.com>
> ---
>  include/linux/tcp.h      |   14 ++-
>  include/net/tcp.h        |   82 +++++++----
>  net/ipv4/tcp_ipv4.c      |  370 ++++++++++++++++++++++++++++--------=
----------
>  net/ipv4/tcp_minisocks.c |   26 +--
>  net/ipv4/tcp_output.c    |   12 +-
>  net/ipv6/tcp_ipv6.c      |  358 +++++++++++++++++++++++++++---------=
--------
>  6 files changed, 531 insertions(+), 331 deletions(-)

This is a huge patch :(

Reading changelog, I dont understand what you did, and why you did this=
=2E

You want to avoid taking the socket lock ? But we need to take it anywa=
y
to process packets.
