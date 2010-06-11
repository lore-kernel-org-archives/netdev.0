From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: Weak host model vs .interface down
Date: Fri, 11 Jun 2010 22:46:13 +0200
Message-ID: <OFE7E910F9.ECF44D01-ONC125773F.007184C4-C125773F.00721849@transmode.se>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se> <4C126514.30905@hp.com> <OFE6F71D1A.A94BE06C-ONC125773F.005C80CF-C125773F.005DF884@transmode.se> <2297DADB-883E-4156-998A-854BE6CAC079@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, Rick Jones <rick.jones2@hp.com>
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:45155 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932520Ab0FKUsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 16:48:31 -0400
In-Reply-To: <2297DADB-883E-4156-998A-854BE6CAC079@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mitchell Erblich <erblichs@earthlink.net> wrote on 2010/06/11 21:50:14:
>
>
> On Jun 11, 2010, at 10:06 AM, Joakim Tjernlund wrote:
>
> > Rick Jones <rick.jones2@hp.com> wrote on 2010/06/11 18:32:20:
> >> Joakim Tjernlund wrote:
> >>> Linux uses the weak host model which makes the IP addresses part of the system
> >>> rather than the interface. However consider this:
> >>>
> >>> System A, eth0 connected to the network
> >>> # > ifconfig eth0 192.168.1.16
> >>> # > ifconfig eth1 192.168.1.17 down
> >>>
> >>> System B
> >>> # > ping 192.168.1.17
> >>> PING 192.168.1.17 (192.168.1.17) 56(84) bytes of data.
> >>> 64 bytes from 192.168.1.17: icmp_seq=1 ttl=64 time=0.618 ms
> >>>
> >>> Isn't it a bit much to respond on 192.168.1.17 when its interface is down?
> >>
> >> As you said at the beginning, the weak end system model presumes the IP address
> >> is part of the system.  Seems to me that means unless one removes the IP address
> >> from the system it is reasonable for the system to continue to respond to that
> >> IP address.  Regardless of what happens to any individual interface.
> >
> > The weak model doesn't go into such detail, it is assumption/impl. detail
> > to assume that the ip address still is part of the system even when the interface
> > is down. One could just as well define interface down as temporarly removing
> > the IP address from the system too. This makes make much more sense to me and
> > if you always want the system to answer on a IP adress you make it an IP alias.
> >
> > Since the current behaviour is a problem to me and routers in general, can
> > we change this? What is the current usage model which needs it to stay as is?
> >
> >>
> >> Now, I wouldn't expect it to continue to respond to 192.168.1.17 through eth1,
> >> but if eth0 is indeed connected to the same broadcast domain, given the
> >> following of the weak end-system model, continuing to respond seems consistent
> >> with enthusiasticaly following the weak end-system model.
> >
> > Dosnt matter if it is in the same broadcast domain, you can use a bridge
> > interface or dummy interface too. It will still respond to 192.168.1.17
> > I can't find a way disable this behaviour, can you?
> >
> > --
>
> Guys
>
> Isn't this the diff between models of a host/end system and a
> router/intermediate system?

Not sure what you mean here, but there is no such assumtion in
the models.

>
> Can you verify that xmit capability on the intf is disabled with the
> down arg?

umm, isn't that true by definition? if an I/F is put into down state, it
cannot xmit nor receive.

>
> IMO, One possible behaviour is to allow the receipt of a magic
> packet to bring up a down system for the "energy star protocol".

isn't that something totally different? I cannot se how that relates
to the matter at hand.

 Jocke

