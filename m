From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 32/34] netfilter: bridge: move br_netfilter out of the
 core
Date: Mon, 29 Sep 2014 15:04:26 -0700
Message-ID: <1412028266.30721.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
	 <1411994363-8451-33-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1411994363-8451-33-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-09-29 at 14:39 +0200, Pablo Neira Ayuso wrote:
> Jesper reported that br_netfilter always registers the hooks since
> this is part of the bridge core. This harms performance for people th=
at
> don't need this.
>=20
> This patch modularizes br_netfilter so it can be rmmod'ed, thus,
> the hooks can be unregistered. I think the bridge netfilter should ha=
ve
> been a separated module since the beginning, Patrick agreed on that.
>=20
> Note that this is breaking compatibility for users that expect that
> bridge netfilter is going to be available after explicitly 'modprobe
> bridge' or via automatic load through brctl.
>=20
> However, the damage can be easily undone by modprobing br_netfilter.
> The bridge core also spots a message to provide a clue to people that
> didn't notice that this has been deprecated.
>=20
> On top of that, the plan is that nftables will not rely on this softw=
are
> layer, but integrate the connection tracking into the bridge layer to
> enable stateful filtering and NAT, which is was bridge netfilter user=
s
> seem to require.
>=20
> This patch still keeps the fake_dst_ops in the bridge core, since thi=
s
> is required by when the bridge port is initialized. So we can safely
> modprobe/rmmod br_netfilter anytime.
>=20
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> Acked-by: Florian Westphal <fw@strlen.de>
> ---

Hmm... What am I missing here ?

$ grep CONFIG_BRIDGE_NETFILTER .config
# CONFIG_BRIDGE_NETFILTER is not set

$ make net/bridge/br_nf_core.o
  CHK     include/config/kernel.release
  CHK     include/generated/uapi/linux/version.h
  CHK     include/generated/utsrelease.h
  CALL    scripts/checksyscalls.sh
  CC [M]  net/bridge/br_nf_core.o
net/bridge/br_nf_core.c:77:1: error: expected identifier or =E2=80=98(=E2=
=80=99 before =E2=80=98{=E2=80=99 token
net/bridge/br_nf_core.c:88:12: error: redefinition of =E2=80=98br_nf_co=
re_init=E2=80=99
net/bridge/br_private.h:762:19: note: previous definition of =E2=80=98b=
r_nf_core_init=E2=80=99 was here
net/bridge/br_nf_core.c:93:6: error: redefinition of =E2=80=98br_nf_cor=
e_fini=E2=80=99
net/bridge/br_private.h:763:20: note: previous definition of =E2=80=98b=
r_nf_core_fini=E2=80=99 was here
make[1]: *** [net/bridge/br_nf_core.o] Error 1
make: *** [net/bridge/br_nf_core.o] Error 2


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
