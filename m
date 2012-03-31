From: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Subject: =?UTF-8?Q?=E7=AD=94=E5=A4=8D:_=E7=AD=94=E5=A4=8D:_=E7=AD=94=E5=A4=8D:?=
	=?UTF-8?Q?_=E7=AD=94=E5=A4=8D:_=5BPATCH=5D_set_fake=5Frtable's_d?=
	=?UTF-8?Q?st_to_NULL_to_avoid_kernel_Oops.?=
Date: Sat, 31 Mar 2012 15:29:53 +0800
Message-ID: <005401cd0f10$10dd14b0$32973e10$%huangpeng@huawei.com>
References: <002501cd0d74$317fd100$947f7300$%huangpeng@huawei.com>
 <1333002975.2325.82.camel@edumazet-glaptop>
 <002601cd0d76$c4987440$4dc95cc0$%huangpeng@huawei.com>
 <1333011120.2325.354.camel@edumazet-glaptop>
 <004501cd0d8f$c4e133b0$4ea39b10$%huangpeng@huawei.com>
 <1333020682.2325.517.camel@edumazet-glaptop>
 <004d01cd0edd$593f3bd0$0bbdb370$%huangpeng@huawei.com>
 <1333172486.2325.3101.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, harry.majun@huawei.com,
	zhoukang7@huawei.com, 'netdev' <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([58.251.152.66]:35796 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab2CaHcf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2012 03:32:35 -0400
In-reply-to: <1333172486.2325.3101.camel@edumazet-glaptop>
Content-language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Eric

Thanks very much for your reply.
I will refine this patch and send it out later.

--------------------------------
Peter Huang(peng)


> -----=E9=82=AE=E4=BB=B6=E5=8E=9F=E4=BB=B6-----
> =E5=8F=91=E4=BB=B6=E4=BA=BA: Eric Dumazet [mailto:eric.dumazet@gmail.=
com]
> =E5=8F=91=E9=80=81=E6=97=B6=E9=97=B4: 2012=E5=B9=B43=E6=9C=8831=E6=97=
=A5 13:41
> =E6=94=B6=E4=BB=B6=E4=BA=BA: Peter Huang (Peng)
> =E6=8A=84=E9=80=81: linux-kernel@vger.kernel.org; harry.majun@huawei.=
com; zhoukang7@huawei.com; 'netdev'
> =E4=B8=BB=E9=A2=98: Re: =E7=AD=94=E5=A4=8D: =E7=AD=94=E5=A4=8D: =E7=AD=
=94=E5=A4=8D: [PATCH] set fake_rtable's dst to NULL to avoid kernel Oop=
s.
>=20
> On Sat, 2012-03-31 at 09:26 +0800, Peter Huang (Peng) wrote:
> > > > >Check net/bridge/br_netfilter.c and commits e688a6048076 (net:=
 introduce
> > > > >DST_NOPEER dst flag )  4adf0af6818f3ea5 (bridge: send correct =
MTU value
> > > > >in PMTU (revised))
> >
> > Hi, Eric
> >
> > I confirmed the patch contents again.
> > For our case, NF_INET_PRE_ROUTING is involved, not NF_BR_LOCAL_IN.
> > It seems pre-routing is not included in the patch you mentioned.
> > BTW, our pkts are all ipv6 DHCP pkts(with MAC 33 33 00 01 00 02).
> >
> > We verified the patch bellow, and this works fine, no WARN_ON happe=
ned.
>=20
> Hi Peter
>=20
> I claim that your patch is not the good one and you need to refine it=
=2E
>=20
> First, code is not needed if CONFIG_BRIDGE_NETFILTER is not set.
>=20
> In fact, if CONFIG_BRIDGE_NETFILTER is not set, compilation will fail
> since fake_rtable doesnt exist in "struct net_bridge", so you fix a b=
ug
> and introduce a new one.
>=20
>   CC [M]  net/bridge/br_forward.o
> net/bridge/br_forward.c: In function =E2=80=98__br_forward=E2=80=99:
> net/bridge/br_forward.c:94: error: =E2=80=98struct sk_buff=E2=80=99 h=
as no member named =E2=80=98_skb_dst=E2=80=99
> net/bridge/br_forward.c:94: error: =E2=80=98struct net_bridge=E2=80=99=
 has no member named =E2=80=98fake_rtable=E2=80=99
> make[1]: *** [net/bridge/br_forward.o] Error 1
> make: *** [_module_net/bridge] Error 2
>=20
>=20
> Then, the test is using obsolete dst internals and cast that should n=
ot
> be in a C file. :
>=20
> if (skb->_skb_dst =3D=3D (unsigned long)&to->br->fake_rtable)
>=20
> So I suggested you take a look at net/bridge/br_netfilter.c code to s=
ee
> how this can be done properly. Maybe you need to add a helper in an
> include file to make this proper.
>=20
> I hope this is now clear to you, because your initial patch cannot be
> applied as is. If you want full credit for this work, you must go a s=
tep
> forward, or else another guy will finish the job.
>=20
> Thanks
