From: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Subject: Re: [PATCH 1/2] Phonet: Implement Pipe Controller to support Nokia
 Slim Modems
Date: Fri, 24 Sep 2010 19:50:55 +0530
Message-ID: <20100924142054.GA1634@bnru01.bnr.st.com>
References: <1285330996-27076-1-git-send-email-kumar.sanghvi@stericsson.com>
 <1285330996-27076-2-git-send-email-kumar.sanghvi@stericsson.com>
 <1285336333.2503.153.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	STEricsson_nomadik_linux <STEricsson_nomadik_linux@list.st.com>,
	Sudeep DIVAKARAN <sudeep.divakaran@stericsson.com>,
	Gulshan KARMANI <gulshan.karmani@stericsson.com>,
	Linus WALLEIJ <linus.walleij@stericsson.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:52193 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753168Ab0IXOVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 10:21:13 -0400
Content-Disposition: inline
In-Reply-To: <1285336333.2503.153.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, Sep 24, 2010 at 15:52:13 +0200, Eric Dumazet wrote:
> Le vendredi 24 septembre 2010 =E0 17:53 +0530, Kumar A Sanghvi a =E9c=
rit :
>=20
> > +static int pipe_get_flow_info(struct sock *sk, struct sk_buff *skb=
,
> > +		u8 *pref_rx_fc, u8 *req_tx_fc)
> > +{
> > +	struct pnpipehdr *hdr =3D pnp_hdr(skb);
> > +	u8 n_sb;
> > +
> > +	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
> > +		return -EINVAL;
>=20
> This is wrong.
>=20
> pskb_may_pull() might change skb->data, so you should do
>=20
> {
> 	struct pnpipehdr *hdr;
> 	u8 n_sb;
>=20
> 	if (!pskb_may_pull(skb, sizeof(*hdr) + 4))
> 		return -EINVAL;
>=20
> 	hdr =3D pnp_hdr(skb);
>=20
Thanks for pointing this out.
I will correct this and post a v2 version of patch.

I will also post a fix for similar problem which now I noticed, based o=
n
your above comment, in pipe_rcv_status function in net/phonet/pep.c

Best regards,
Kumar.
