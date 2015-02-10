From: Vasily Averin <vvs@parallels.com>
Subject: Re: bride: IPv6 multicast snooping enhancements
Date: Tue, 10 Feb 2015 11:44:29 +0300
Message-ID: <54D9C4ED.6040601@parallels.com>
References: <1378253619-23918-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	bridge@lists.linux-foundation.org,
	Adam Baker <linux@baker-net.linuxfoundation.org>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: =?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@web.de>,
	netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1378253619-23918-1-git-send-email-linus.luessing@web.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This patch prevent forwarding of ICMPv6 in bridges,
so containers/VMs with virtual eth adapters connected in local bridge can=
not ping each other via ipv6 (but can do it via ipv4)

Could you please clarify, is it expected behavior?
Do we need to enable multicast routing or multicast_snooping on all local=
 ports on such bridges to enable just ICMPv6?
I believe ICMPv6 is an exception and should not be filtered by multicast =
spoofing.

Thank you,
	Vasily Averin

On 04.09.2013 04:13, Linus L=C3=BCssing wrote:
> Hi,
>=20
> Here are two, small feature changes I would like to submit to increase
> the usefulness of the multicast snooping of the bridge code.
>=20
> The first patch is an unaltered one I had submitted before, but since i=
t
> got no feedback I'm resubmitting it here for net-next. With the recentl=
y
> added patch to disable snooping if there is no querier (b00589af + 248b=
a8ec05
> + 8d50af4fb), it should be a safe choice now (without these, patch 1/2 =
would
> have introduced another potential for lost IPv6 multicast packets).
>=20
> Both conceptually and also with some testing and fuzzing, I couldn't sp=
ot
> any more causes for potential packet loss. And since the multicast snoo=
ping
> code has now been tried by various people, I think it should be a safe
> choice to apply the multicast snooping not only for IPv6 multicast pack=
ets
> with a scope greater than link-local, but also for packets of exactly t=
his
> scope. The IPv6 standard mandates MLD reports for link-local multicast,=
 too,
> so we can safely snoop them as well (in contrast to IPv4 link-local).
>=20
> Cheers, Linus
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
>=20
>=20
