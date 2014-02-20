From: Florian Westphal <fw@strlen.de>
Subject: Re: BUG: ip6tables IPv6-REDIRECT over bridges
Date: Thu, 20 Feb 2014 20:32:31 +0100
Message-ID: <20140220193231.GB7119@breakpoint.cc>
References: <1392920071.66303.YahooMailNeo@web172306.mail.ir2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"\"David S. Miller\"" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Artie Hamilton <artiemhamilton@yahoo.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392920071.66303.YahooMailNeo@web172306.mail.ir2.yahoo.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Artie Hamilton <artiemhamilton@yahoo.com> wrote:
> Now the same thing should be done for IPv6. It should works quite sim=
ilar
> (I just=A0assume the above mentioned steps are already done):
>=20
> $ sysctl -w net.ipv6.conf.br0.accept_ra=3D2
> $ sysctl -w net.bridge.bridge-nf-call-ip6tables=3D1
> $ ip6tables -t nat -A PREROUTING -p tcp -m tcp --dport 8080 -j REDIRE=
CT --to-ports 81
>=20
> But here is the problem: Connections will not be started. I see for e=
xample
> connections getting started to the service like this on the client:

Yes, because bridge layer does not detect when addresses have been
rewritten.

The check is only implemented for ipv4, see dnat_took_place use in br_n=
etfilter.c
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
