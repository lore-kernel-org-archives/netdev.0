From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Thu, 22 Dec 2011 07:38:06 +0100
Message-ID: <20111222063806.GP6348@secunet.com>
References: <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4EF2117F.6000803@bootc.net>
 <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <4EF23BF2.4000601@bootc.net>
 <1324499332.2621.7.camel@edumazet-laptop>
 <1324500775.2621.9.camel@edumazet-laptop>
 <4EF2568C.6040006@bootc.net>
 <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
 <1324528656.2621.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Boot <bootc@bootc.net>, lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1324528656.2621.19.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2011 at 05:37:36AM +0100, Eric Dumazet wrote:
> Le mercredi 21 d=E9cembre 2011 =E0 23:12 +0000, Chris Boot a =E9crit =
:
> >=20
> > (gdb) list *ip_fragment+0x9d
> > 0xffffffff812a62e1 is in ip_fragment (include/net/dst.h:209).
> > 204		return dst_metric(dst, RTAX_FEATURES) & feature;
> > 205	}
> > 206=09
> > 207	static inline u32 dst_mtu(const struct dst_entry *dst)
> > 208	{
> > 209		return dst->ops->mtu(dst);
> > 210	}
> > 211=09
> > 212	/* RTT metrics are stored in milliseconds for user ABI, but use=
d as jiffies */
>=20
> This one is different, its not IPv6 related but IPv4 :
>=20
> fake_dst_ops lacks a .mtu() field
>=20
> Bug added in commit 618f9bc74a039da76 (net: Move mtu handling down to
> the protocol depended handlers)
>=20

Before I did this patch, I changed the .default_mtu field of "struct ds=
t_ops"
to .mtu and converted all users of default_mtu to mtu. fake_dst_ops nev=
er
had a default_mtu field, so I did not touch it. I guess this bug is arr=
ound
since fake_dst_ops exists. It's now just much easier to trigger as comm=
it
618f9bc74a039da76 changed dst_mtu() to call dst->ops->mtu() uncondition=
ally.
