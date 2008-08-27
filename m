From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Wed, 27 Aug 2008 19:07:01 +0200
Message-ID: <48B589B5.7050303@cosmosbay.com>
References: <48B5815D.4010005@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp28.orange.fr ([80.12.242.101]:37557 "EHLO smtp28.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbYH0RHK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 13:07:10 -0400
In-Reply-To: <48B5815D.4010005@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> After turning IP_XXX_STATS, TCP_XXX_STATS and NET_XXX_STATS from
> macros into functions the net/ipv4/built-in.o shrank significantly:
>=20
> add/remove: 14/0 grow/shrink: 0/67 up/down: 482/-2246 (-1764)
>=20
> Turning the CONFIG_NET_NS option on makes this shrink even larger:
>=20
> add/remove: 14/0 grow/shrink: 0/67 up/down: 478/-2646 (-2168)
>=20
> So the question is - what was the reason to keep those as macros?
> I thought about the possible performance questions, but netperf
> didn't show any (I admit I just cannot cook it properly).
>=20
> The sample patch is here, but it's not good (EXPORTs for ipv6
> and a better place for functions rather than net/ipv4/af_inet.c
> are required).
>=20
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>=20


I dont know, but passing all those "struct net *net" to every=20
network function in the kernel sounds overkill, especially for
!CONFIG_NET_NS users. This is pure bloat.

We could define two macros so that function prototypes dont include
useless pointers, especially on arches where only first and second
parameter is passed in eax and edx register ;)

#ifdef CONFIG_NET_NS
# define VNETPTR ,struct net *net
# define NETPTR  net
#else
# define VNETPTR
# defint NETPTR  &init_net
#endif

=2E..
void TCP_DEC_STATS(int field VNETPTR);
=2E..
void TCP_DEC_STATS(int field VNETPTR)
{
	SNMP_DEC_STATS((NETPTR)->mib.tcp_statistics, field);
}
=2E..



