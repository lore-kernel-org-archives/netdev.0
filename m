From: "Daniel 'NebuchadnezzaR' Dehennin" <nebuchadnezzar@nerim.net>
Subject: [IPV6] problem with xfrm6_tunnel_check_size
Date: Sun, 12 Oct 2003 14:04:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87vfquslvn.fsf@nerim.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Net <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I try to compile a 2.6.0-test7 with usagi 20031012 but I have the followi=
ng
error:

net/built-in.o(.text+0x599f3): dans la fonction =AB xfrm_check_output =BB=
:
: undefined reference to `xfrm6_tunnel_check_size'
make[1]: *** [.tmp_vmlinux1] Erreur 1
make[1]: Leaving directory `/usr/src/linux-2.6.0-test7'
make: *** [stamp-build] Erreur 2

I try to figure out the problem by myself but I don't manage to do it.
Here is what I do:

Search xfrm6_tunnel_check_size in net/:
net/ipv6/ipv6_syms.c:EXPORT_SYMBOL(xfrm6_tunnel_check_size);
net/ipv6/xfrm6_tunnel.c:int xfrm6_tunnel_check_size(struct sk_buff *skb)
net/ipv6/xfrm6_tunnel.c:        if ((err =3D xfrm6_tunnel_check_size(skb)=
) !=3D 0)
net/xfrm/xfrm_output.c:                 err =3D xfrm6_tunnel_check_size(s=
kb);

Search xfrm6_tunnel_check_size in include/:
include/net/xfrm.h:extern int xfrm6_tunnel_check_size(struct sk_buff *skb=
);

Search xfrm4_tunnel_check_size in net/:
net/ipv4/xfrm4_tunnel.c:int xfrm4_tunnel_check_size(struct sk_buff *skb)
net/ipv4/xfrm4_tunnel.c:        if ((err =3D xfrm4_tunnel_check_size(skb)=
) !=3D 0)
net/xfrm/xfrm_export.c:EXPORT_SYMBOL(xfrm4_tunnel_check_size);
net/xfrm/xfrm_output.c:                 err =3D xfrm4_tunnel_check_size(s=
kb);

Search xfrm4_tunnel_check_size in include/:
include/net/xfrm.h:extern int xfrm4_tunnel_check_size(struct sk_buff *skb=
);

I see that building xfrm we use xfrm_export in with
xfrm4_tunnel_check_size is exported but xfrm6_tunnel_check_size is in
ipv6/ip6_syms.c, is this a way to solve the problem ?

Is there a reason to have an ipv6_syms and not an ipv4_syms ?

Thanks.

--=20
Daniel 'NebuchadnezzaR' Dehennin
