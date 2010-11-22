From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] netfilter: nf_conntrack_sip: Handle Cisco 7941/7945
 IP phones
Date: Mon, 22 Nov 2010 08:52:14 +0100
Message-ID: <1290412334.2756.141.camel@edumazet-laptop>
References: <f0955e6c2110044fa058d0f3ecf945ca@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kevin Cernekee <cernekee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f0955e6c2110044fa058d0f3ecf945ca@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 21 novembre 2010 =C3=A0 18:40 -0800, Kevin Cernekee a =C3=A9=
crit :
> [v3:
>   Only activate the new forced_dport logic if the IP matches, but the
>   port does not. ]
>=20
> Most SIP devices use a source port of 5060/udp on SIP requests, so th=
e
> response automatically comes back to port 5060:
>=20
> phone_ip:5060 -> proxy_ip:5060   REGISTER
> proxy_ip:5060 -> phone_ip:5060   100 Trying
>=20
> The newer Cisco IP phones, however, use a randomly chosen high source
> port for the SIP request but expect the response on port 5060:
>=20
> phone_ip:49173 -> proxy_ip:5060  REGISTER
> proxy_ip:5060 -> phone_ip:5060   100 Trying
>=20
> Standard Linux NAT, with or without nf_nat_sip, will send the reply b=
ack
> to port 49173, not 5060:
>=20
> phone_ip:49173 -> proxy_ip:5060  REGISTER
> proxy_ip:5060 -> phone_ip:49173  100 Trying
>=20
> But the phone is not listening on 49173, so it will never see the rep=
ly.
>=20
> This patch modifies nf_*_sip to work around this quirk by extracting
> the SIP response port from the Via: header, iff the source IP in the
> packet header matches the source IP in the SIP request.
>=20
> Signed-off-by: Kevin Cernekee <cernekee@gmail.com>
> ---

Thanks for doing this work Keven !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
