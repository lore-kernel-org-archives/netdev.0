From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: generic 802.11 stack
Date: Sat, 2 Oct 2004 01:25:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410020125.40669.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <200410011630.59465.vkondra@mail.ru> <20041001155310.515ee09e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6206511.VO1UjDSxoh";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mcgrof@studorgs.rutgers.edu,
        acx100-devel@lists.sourceforge.net, prism54-devel@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041001155310.515ee09e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart6206511.VO1UjDSxoh
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Saturday 02 October 2004 00:53, David S. Miller wrote:
DS>
DS> Why this change?
DS>
DS> -extern void hh_data_is_too_small(void);
DS> +static void hh_data_is_too_small(void)
DS> +{
DS> +    printk(KERN_ERR "hh_data_is_too_small\n");
DS> +}

My misunderstanding. Sorry.

DS>
DS> We don't define the function because it is meant to
DS> cause a compile time error if hh->hh_data is too small to
DS> hold the full p80211_data_header structure.  Please undo
DS> this change.
DS>
DS> And therefore undo this change too:
DS>
DS> - if (sizeof(hh->hh_data) < sizeof(*p))
DS> + if (sizeof(hh->hh_data) < sizeof(*p)) {
DS>    hh_data_is_too_small();
DS> +        return -1;
DS> +    }

As above.

DS>
DS> Next, what's this?
DS>
DS> - dev->hard_header =3D p80211_header;
DS> + dev->hard_header     =3D p80211_header;
DS>   dev->rebuild_header  =3D p80211_rebuild_header;
DS>
DS> Your merely changing the tab character after dev->hard_header
DS> into spaces.  Please don't do this.  This makes a lot of white
DS> space noise when making diffs against the original davem-p80211
DS> code thus making it harder to review the changes you actually made.

My editor did it for me. I'll be more carefull to check this behind the sce=
ne=20
things. Maybe, I'll do one patch to do all spaces accordingly to kernel=20
coding style, and since that will follow it.

DS>
DS> Next:
DS>
DS> +    dev->mtu                =3D 2304;
DS> +    dev->type               =3D ARPHRD_IEEE80211;
DS>
DS> Is this really the correct default MTU for wireless devices?

Yes, 802.11e (QoS) defines this value.

DS>
DS> @@ -342,7 +343,7 @@ int p80211_recv_cfackpoll(struct sk_buff
DS>  static struct packet_type p80211_packet_type =3D {
DS>   .type =3D __constant_htons(ETH_P_802_11),
DS>   .func =3D p80211_rcv,
DS> - .data =3D (void *) 1, /* understands shared SKBs */
DS> + .af_packet_priv =3D (void *) 1, /* understands shared SKBs */
DS>  };
DS>
DS> You can just remove this line entirely for 2.6.x kernels.

Thanks, I will. I was confused by this member and did simplest trick to mak=
e=20
it compile.

DS>
DS> Otherwise looks fine :-)

Really, thus far I did almost nothing. It is just foundation for playing wi=
th=20
stack. My intention was to decouple driver and stack ASAP to enable separat=
e=20
development for each part.

Next step I will do data path, with some code to enable QoS 26 byte headers=
=20
but without real QoS, which is, by the way, pretty complicated as defined i=
n=20
TGe. May be, it is better to start with WME w.r.t QoS.

Then, it is management's turn. Association, scanning.

Then, once again, data path. Fragmentation, reassembly. Framework for=20
security.

Then - let's see how this will develop.

--nextPart6206511.VO1UjDSxoh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBXed0qxdj7mhC6o0RAo7iAJ0QM7tZtzzcVIKzG1GDm2h3iQbcsgCfdP06
k+A04teh0Hj/6vwDpiOZR8c=
=53Am
-----END PGP SIGNATURE-----

--nextPart6206511.VO1UjDSxoh--
