From: Florian Westphal <fw@strlen.de>
Subject: Re: [netfilter-core] [PATCH] net: netfilter: fix GCC uninitialized
 warning
Date: Fri, 6 Nov 2015 20:07:05 +0100
Message-ID: <20151106190705.GA20345@breakpoint.cc>
References: <1446835694-6967-1-git-send-email-0x7f454c46@gmail.com>
 <20151106191008.GA2362@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	kadlec@blackhole.kfki.hu, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151106191008.GA2362@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Fri, Nov 06, 2015 at 09:48:14PM +0300, Dmitry Safonov wrote:
> > With x86_64_defconfig:
> > GCC thinks that in nfulnl_recv_config flags parameter is not inited=
 but
> > it was under the same condition (nfula[NFULA_CFG_FLAGS] =3D=3D true=
).
> > Suppress this warning:
> > 	net/netfilter/nfnetlink_log.c: In function =E2=80=98nfulnl_recv_co=
nfig=E2=80=99:
> > 	net/netfilter/nfnetlink_log.c:320:14: warning: =E2=80=98flags=E2=80=
=99 may be used uninitialized in this function [-Wmaybe-uninitialized]
> >   	inst->flags =3D flags;
> > 	            ^
> > Signed-off-by: Dmitry Safonov <0x7f454c46@gmail.com>
> > ---
> >  net/netfilter/nfnetlink_log.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlin=
k_log.c
> > index 06eb48fceb42e4..d65f3b987b7f13 100644
> > --- a/net/netfilter/nfnetlink_log.c
> > +++ b/net/netfilter/nfnetlink_log.c
> > @@ -825,7 +825,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk=
_buff *skb,
> >  	struct net *net =3D sock_net(ctnl);
> >  	struct nfnl_log_net *log =3D nfnl_log_pernet(net);
> >  	int ret =3D 0;
> > -	u16 flags;
> > +	u16 flags =3D 0; /* GCC uninitialized */
>=20
>         u16 uninitialized_var(flags); ?

I also see warnings in nfqueue:

net/netfilter/nfnetlink_queue.c:1083:11: warning: 'nfnl_ct' may be used=
 uninitialized in this function [-Wmaybe-uninitialized]
net/netfilter/nfnetlink_queue.c:519:19: warning: 'nfnl_ct' may be used =
uninitialized in this function [-Wmaybe-uninitialized]

Both are false positives, but it would be nice if we could silence
these.
