From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v3] netfilter: nf_conntrack_sip: Handle Cisco 7941/7945
 IP phones
Date: Mon, 17 Dec 2012 01:44:57 +0100
Message-ID: <20121217004457.GA12234@1984>
References: <f0955e6c2110044fa058d0f3ecf945ca@localhost>
 <1290412334.2756.141.camel@edumazet-laptop>
 <1355703441.18919.6.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Kevin Cernekee <cernekee@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1355703441.18919.6.camel@shinybook.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Mon, Dec 17, 2012 at 12:17:21AM +0000, David Woodhouse wrote:
> On Mon, 2010-11-22 at 08:52 +0100, Eric Dumazet wrote:
> > Le dimanche 21 novembre 2010 =E0 18:40 -0800, Kevin Cernekee a =E9c=
rit :
> > > [v3:
> > >   Only activate the new forced_dport logic if the IP matches, but=
 the
> > >   port does not. ]
> > >=20
> > > Most SIP devices use a source port of 5060/udp on SIP requests, s=
o the
> > > response automatically comes back to port 5060:
> > >=20
> > > phone_ip:5060 -> proxy_ip:5060   REGISTER
> > > proxy_ip:5060 -> phone_ip:5060   100 Trying
> > >=20
> > > The newer Cisco IP phones, however, use a randomly chosen high so=
urce
> > > port for the SIP request but expect the response on port 5060:
> > >=20
> > > phone_ip:49173 -> proxy_ip:5060  REGISTER
> > > proxy_ip:5060 -> phone_ip:5060   100 Trying
> > >=20
> > > Standard Linux NAT, with or without nf_nat_sip, will send the rep=
ly back
> > > to port 49173, not 5060:
> > >=20
> > > phone_ip:49173 -> proxy_ip:5060  REGISTER
> > > proxy_ip:5060 -> phone_ip:49173  100 Trying
> > >=20
> > > But the phone is not listening on 49173, so it will never see the=
 reply.
> > >=20
> > > This patch modifies nf_*_sip to work around this quirk by extract=
ing
> > > the SIP response port from the Via: header, iff the source IP in =
the
> > > packet header matches the source IP in the SIP request.
> > >=20
> > > Signed-off-by: Kevin Cernekee <cernekee@gmail.com>
> > > ---
> >=20
> > Thanks for doing this work Keven !
> >=20
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> What happened to this? OpenWRT is still carrying it, and it broke in
> 3.7. Here's a completely untested update...

I requested Kevin to resend a new version based on the current kernel
tree while spinning on old pending patches since I have no access to
that hardware, but no luck.

So I'll review this and, since OpenWRT is carrying, I guess we can get
this into net-next merge window.

Thanks for the reminder.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
