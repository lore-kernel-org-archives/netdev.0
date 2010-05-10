From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: VLAN I/F's and TX queue.
Date: Mon, 10 May 2010 16:54:40 +0200
Message-ID: <OF60B75A13.F85EAE42-ONC125771F.00518947-C125771F.0051E8DC@transmode.se>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se>
	 <1273222403.2261.26.camel@edumazet-laptop>  <4BE81793.3060905@trash.net> <1273502195.2221.4.camel@edumazet-laptop> <4BE81B24.4020601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:50774 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971Ab0EJO5s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 10:57:48 -0400
In-Reply-To: <4BE81B24.4020601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote on 2010/05/10 16:41:40:
>
> Eric Dumazet wrote:
> > Le lundi 10 mai 2010 =E0 16:26 +0200, Patrick McHardy a =E9crit :
> >
> >> Is the intention just to avoid accounting the packet as dropped?
> >> That seems fine to me since in case of NET_XMIT_CN its actually
> >> not the currently transmitted packet that was dropped.
> >>
> >> But part of the intention of the above mentioned patch was actuall=
y
> >> to inform higher layers of congestion so they can take action if
> >> desired, which would be defeated by this patch.
> >>
> >
> > I see, so maybe we want following patch instead ?
> >
> > (letting NET_XMIT_CN be given to caller, but accounting current pac=
ket
> > as transmitted ?)
>
> Perfect, thanks. I'd suggest to change macvlan in a similar fashion
> for consistency though.
>
> In any case please feel free to add my
>
> Acked-by: Patrick McHardy <kaber@trash.net>

hmm, as I don't follow this could you tell me where the dropped pkgs
are accounted in my case:
 eth0      Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:8886910 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8880219 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:100
           RX bytes:1626842951 (1.5 GiB)  TX bytes:1555540810 (1.4 GiB)

 eth0.1    Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:2163164 errors:0 dropped:0 overruns:0 frame:0
           TX packets:2161943 errors:0 dropped:98 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:2467090557 (2.2 GiB)  TX bytes:2480246455 (2.3 GiB)

 eth0.1.1  Link encap:Ethernet  HWaddr 00:AA:BB:CC:DD:EE
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:2163164 errors:0 dropped:0 overruns:0 frame:0
           TX packets:2161943 errors:0 dropped:98 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:2458437901 (2.2 GiB)  TX bytes:2471598683 (2.3 GiB)

