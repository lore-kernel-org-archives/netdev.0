From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN I/F's and TX queue.
Date: Mon, 10 May 2010 17:14:56 +0200
Message-ID: <1273504496.2221.14.camel@edumazet-laptop>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>
	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se>
	 <1273222403.2261.26.camel@edumazet-laptop>  <4BE81793.3060905@trash.net>
	 <1273502195.2221.4.camel@edumazet-laptop> <4BE81B24.4020601@trash.net>
	 <OF60B75A13.F85EAE42-ONC125771F.00518947-C125771F.0051E8DC@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36123 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752434Ab0EJPPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 11:15:01 -0400
Received: by fxm7 with SMTP id 7so186041fxm.19
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 08:15:00 -0700 (PDT)
In-Reply-To: <OF60B75A13.F85EAE42-ONC125771F.00518947-C125771F.0051E8DC@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 mai 2010 =C3=A0 16:54 +0200, Joakim Tjernlund a =C3=A9crit =
:
> Patrick McHardy <kaber@trash.net> wrote on 2010/05/10 16:41:40:
> >
> > Eric Dumazet wrote:
> > > Le lundi 10 mai 2010 =C3=A0 16:26 +0200, Patrick McHardy a =C3=A9=
crit :
> > >
> > >> Is the intention just to avoid accounting the packet as dropped?
> > >> That seems fine to me since in case of NET_XMIT_CN its actually
> > >> not the currently transmitted packet that was dropped.
> > >>
> > >> But part of the intention of the above mentioned patch was actua=
lly
> > >> to inform higher layers of congestion so they can take action if
> > >> desired, which would be defeated by this patch.
> > >>
> > >
> > > I see, so maybe we want following patch instead ?
> > >
> > > (letting NET_XMIT_CN be given to caller, but accounting current p=
acket
> > > as transmitted ?)
> >
> > Perfect, thanks. I'd suggest to change macvlan in a similar fashion
> > for consistency though.
> >
> > In any case please feel free to add my
> >
> > Acked-by: Patrick McHardy <kaber@trash.net>
>=20
> hmm, as I don't follow this could you tell me where the dropped pkgs
> are accounted in my case:
>  eth0      Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>            RX packets:8886910 errors:0 dropped:0 overruns:0 frame:0
>            TX packets:8880219 errors:0 dropped:0 overruns:0 carrier:0
>            collisions:0 txqueuelen:100
>            RX bytes:1626842951 (1.5 GiB)  TX bytes:1555540810 (1.4 Gi=
B)
>=20
>  eth0.1    Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>            RX packets:2163164 errors:0 dropped:0 overruns:0 frame:0
>            TX packets:2161943 errors:0 dropped:98 overruns:0 carrier:=
0
>            collisions:0 txqueuelen:0
>            RX bytes:2467090557 (2.2 GiB)  TX bytes:2480246455 (2.3 Gi=
B)
>=20
>  eth0.1.1  Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>            RX packets:2163164 errors:0 dropped:0 overruns:0 frame:0
>            TX packets:2161943 errors:0 dropped:98 overruns:0 carrier:=
0
>            collisions:0 txqueuelen:0
>            RX bytes:2458437901 (2.2 GiB)  TX bytes:2471598683 (2.3 Gi=
B)
>=20
> -

As I already said to you, this is a side effect, because your eth0.1.1
and eth0.1 have no queue.

Packet is not dropped, its only a congestion indication.

If you use a queue on eth0.1.1, queue itself handle the queueing
(obviously), and queue drops are not reported in 'ifconfig -a', but in=20
'tc -s -d qdisc'



