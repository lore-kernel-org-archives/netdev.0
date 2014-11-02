From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: fix netfilter/NF_BR_LOCAL_OUT for own,
 locally generated queries
Date: Mon, 3 Nov 2014 06:01:46 +0800
Message-ID: <20141102220145.GA25604@gondor.apana.org.au>
References: <1411342364-4791-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <stephen@networkplumber.org>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@web.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1411342364-4791-1-git-send-email-linus.luessing@web.de>
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

On Mon, Sep 22, 2014 at 01:32:44AM +0200, Linus L=C3=BCssing wrote:
> Ebtables on the OUTPUT chain (NF_BR_LOCAL_OUT) would not work as expect=
ed
> for both locally generated IGMP and MLD queries. The IP header specific
> filter options are off by 14 Bytes for netfilter (actual output on
> interfaces is fine).
>=20
> NF_HOOK()=E2=80=AFexpects the skb->data to point to the IP header, not =
the
> ethernet one (while dev_queue_xmit()=E2=80=AFdoes not). Luckily there i=
s an
> br_dev_queue_push_xmit() helper function already - let's just use that.
>=20
> Introduced by eb1d16414339a6e113d89e2cca2556005d7ce919
> ("bridge: Add core IGMP snooping support")
>=20
> Ebtables example:
>=20
> $ ebtables -I OUTPUT -p IPv6 -o eth1 --logical-out br0 \
> 	--log --log-level 6 --log-ip6 --log-prefix=3D"~EBT: " -j DROP
>=20
> before (broken):
>=20
> ~EBT:  IN=3D OUT=3Deth1 MAC source =3D 02:04:64:a4:39:c2 \
> 	MAC dest =3D 33:33:00:00:00:01 proto =3D 0x86dd IPv6 \
> 	SRC=3D64a4:39c2:86dd:6000:0000:0020:0001:fe80 IPv6 \
> 	DST=3D0000:0000:0000:0004:64ff:fea4:39c2:ff02, \
> 	IPv6 priority=3D0x3, Next Header=3D2
>=20
> after (working):
>=20
> ~EBT:  IN=3D OUT=3Deth1 MAC source =3D 02:04:64:a4:39:c2 \
> 	MAC dest =3D 33:33:00:00:00:01 proto =3D 0x86dd IPv6 \
> 	SRC=3Dfe80:0000:0000:0000:0004:64ff:fea4:39c2 IPv6 \
> 	DST=3Dff02:0000:0000:0000:0000:0000:0000:0001, \
> 	IPv6 priority=3D0x0, Next Header=3D0
>=20
> Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
