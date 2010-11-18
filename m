From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: error while building the kernel Mainline
Date: Thu, 18 Nov 2010 18:48:17 +0100
Message-ID: <1290102497.2781.242.camel@edumazet-laptop>
References: <AANLkTikToBjx-4go9mAFCcnTQ5X4Su+57ODoY9C5y_7f@mail.gmail.com>
	 <1290093135.2781.167.camel@edumazet-laptop>  <4CE561A2.2020600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-net@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Simon Horman <horms@verge.net.au>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CE561A2.2020600@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 18 novembre 2010 =C3=A0 09:25 -0800, Justin P. Mattock a =C3=A9=
crit :
> On 11/18/2010 07:12 AM, Eric Dumazet wrote:
> > Le jeudi 18 novembre 2010 =C3=A0 06:36 -0800, Justin Mattock a =C3=A9=
crit :
> >> hit this yesterday, and havent had time to look at it, to see if i=
ts a
> >> simple fix
> >>
> >>    MODPOST vmlinux.o
> >> WARNING: modpost: Found 1 section mismatch(es).
> >> To see full details build your kernel with:
> >> 'make CONFIG_DEBUG_SECTION_MISMATCH=3Dy'
> >>    GEN     .version
> >>    CHK     include/generated/compile.h
> >>    UPD     include/generated/compile.h
> >>    CC      init/version.o
> >>    LD      init/built-in.o
> >>    LD      .tmp_vmlinux1
> >> net/built-in.o: In function `handle_response_icmp':
> >> ip_vs_core.c:(.text+0x2b5c4): undefined reference to `nf_conntrack=
_untracked'
> >> net/built-in.o: In function `T.925':
> >> ip_vs_core.c:(.text+0x2cbbd): undefined reference to `nf_conntrack=
_untracked'
> >> net/built-in.o: In function `ip_vs_null_xmit':
> >> (.text+0x310da): undefined reference to `nf_conntrack_untracked'
> >> net/built-in.o: In function `ip_vs_tunnel_xmit':
> >> (.text+0x311e3): undefined reference to `nf_conntrack_untracked'
> >> net/built-in.o: In function `ip_vs_nat_xmit':
> >> (.text+0x3176f): undefined reference to `nf_conntrack_untracked'
> >> net/built-in.o:(.text+0x3199d): more undefined references to
> >> `nf_conntrack_untracked' follow
> >> make: *** [.tmp_vmlinux1] Error 1
> >>
> >> has there been anything sent forward for this yet?
> >>
> >
> > Try to find out why net/netfilter/nf_conntrack_core.c is not compil=
ed ?
>=20
> seems it is compiling, it's after the compiling when this breaks
>=20
> >
> > ./net/netfilter/nf_conntrack_core.c:65:DEFINE_PER_CPU(struct nf_con=
n, nf_conntrack_untracked);
> > ./net/netfilter/nf_conntrack_core.c:66:EXPORT_PER_CPU_SYMBOL(nf_con=
ntrack_untracked);
> >
> >
> >
> >
>=20
> Justin P. Mattock


Let me guess...

net/netfilter/nf_conntrack_core is compiled as a module, and ip_vs
statically (in vmlinux) ?

CONFIG_NF_CONNTRACK=3Dm
CONFIG_IP_VS=3Dy

We probably need some Kconfig magic ;)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
