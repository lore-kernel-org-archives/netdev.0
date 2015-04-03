From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 4/9 net-next] ipv6: replace if/BUG by BUG_ON
Date: Fri, 3 Apr 2015 22:02:32 +0200 (CEST)
Message-ID: <911278303.335976.1428091352576.open-xchange@webmail.nmp.proximus.be>
References: <1427749998-28464-1-git-send-email-fabf@skynet.be> <1427749998-28464-4-git-send-email-fabf@skynet.be> <551A1983.40408@miraclelinux.com> <20150331.111752.1605776715849912657.davem@davemloft.net>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pablo@netfilter.org, coreteam@netfilter.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	netfilter-devel@vger.kernel.org, steffen.klassert@secunet.com,
	jmorris@namei.org, kuznet@ms2.inr.ac.ru, kadlec@blackhole.kfki.hu,
	kaber@trash.net
To: hideaki.yoshifuji@miraclelinux.com,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150331.111752.1605776715849912657.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 31 March 2015 at 17:17 David Miller <davem@davemloft.net> wrote:
>
>
> From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> Date: Tue, 31 Mar 2015 12:50:27 +0900
>
> > Hi,
> >
> > Fabian Frederick wrote:
> >> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> >> ---
> >>=C2=A0 net/ipv6/addrconf.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 3 +--
> >>=C2=A0 net/ipv6/esp6.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 3 +--
> >>=C2=A0 net/ipv6/netfilter/nf_conntrack_reasm.c | 3 +--
> >>=C2=A0 3 files changed, 3 insertions(+), 6 deletions(-)
> >>
> >> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> >> index 2660263..e205918 100644
> >> --- a/net/ipv6/addrconf.c
> >> +++ b/net/ipv6/addrconf.c
> >> @@ -4805,8 +4805,7 @@ static int inet6_set_link_af(struct net_devi=
ce *dev,
> >> const struct nlattr *nla)
> >>=C2=A0 =C2=A0 if (!idev)
> >>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EAFNOSUPPORT;
> >>=C2=A0
> >> -=C2=A0 if (nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0)
> >> -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG();
> >> +=C2=A0 BUG_ON(nla_parse_nested(tb, IFLA_INET6_MAX, nla, NULL) < 0=
);
> >>=C2=A0
> >
> > NACK, I do not prefer using BUG_ON() with side effects.
>
> Agreed, I do not like these changes at all and will not be
> applying them.

I guess patches like these should be reverted then ?

e3f0b86b996d
"ipv6: Use BUG_ON"

8242fc33925c
"net: ipv6: Use BUG_ON"

Some existing BUG_ON() as well ? ; eg second one in net/decnet/dn_rules=
=2Ec:
void __init dn_fib_rules_init(void)
{
=C2=A0 =C2=A0 =C2=A0 =C2=A0 dn_fib_rules_ops =3D
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 fib_rules_regis=
ter(&dn_fib_rules_ops_template, &init_net);
=C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(IS_ERR(dn_fib_rules_ops));
=C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(fib_default_rule_add(dn_fib_rules_op=
s, 0x7fff,
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RT_TABLE_MAIN, 0))=
;
}

Regards,
=46abian
