From: Vladimir Kondratiev <vkondra@mail.ru>
Subject: Re: generic 802.11 stack
Date: Tue, 7 Sep 2004 21:41:54 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409072141.58893.vkondra@mail.ru>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <200409072106.28334.vkondra@mail.ru> <20040907110813.6b463f3a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6771719.9nFv9mMZL8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20040907110813.6b463f3a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--nextPart6771719.9nFv9mMZL8
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 07 September 2004 21:08, David S. Miller wrote:
DS> On Tue, 7 Sep 2004 21:06:24 +0300
DS> Vladimir Kondratiev <vkondra@mail.ru> wrote:
DS>
DS> > May be I did not stated the question clearly. This information need to
 be DS> > specified per packet. So question ramains: how to specify PHY info
 per skb. DS>
DS> Use the skb->cb[] area, create:
DS>
DS> struct p80211_skb_cb {
DS>  int rate;
DS>  int channel;
DS>  /* whatever... */
DS> };
DS>
DS> #define P80211_SKB_CB(skb)  ((struct p80211_skb_cb *)((skb)->cb))

This should be done in generic way. This information used to communicate=20
berween particular driver and generic stack. For example, Rx PHY info and T=
x=20
status info should be used for in-stack generic rate scaling algorithm.

To complicate it a bit, cb[] is only 48 bytes long. PHY info may easily exc=
eed=20
this size, so it's better to allocate something and free it in destructor.

But again, point is this structure should be generic since it is used by=20
stack.

--nextPart6771719.9nFv9mMZL8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBPgD2qxdj7mhC6o0RAibiAJ0TQONrdNoltPzdbwE/ALFg9SCmegCglgwM
hlrmFHhTK5SQ/pGISBiqHIY=
=a5zw
-----END PGP SIGNATURE-----

--nextPart6771719.9nFv9mMZL8--
