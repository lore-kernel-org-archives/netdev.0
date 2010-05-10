From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: VLAN I/F's and TX queue.
Date: Mon, 10 May 2010 16:50:20 +0200
Message-ID: <OFC83B46CB.0E764A8E-ONC125771F.005109E4-C125771F.00518338@transmode.se>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se> <1273222403.2261.26.camel@edumazet-laptop> <OF803EE436.793B95D8-ONC125771C.003295C9-C125771C.00341AFF@transmode.se> <4BE8191C.8020302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:50334 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751516Ab0EJOwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 10:52:49 -0400
In-Reply-To: <4BE8191C.8020302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> wrote on 2010/05/10 16:33:00:
>
> Joakim Tjernlund wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/05/07 10:53:23:
> >>> 3) I would expect lost pkgs to be accounted on eth0 instead of
> >>>    the VLAN interface(s) since that is where the pkg is lost, why
> >>>    isn't it so?
> >> You try to send packets on eth0.XXX, some are dropped, and accounted for
> >> on eth0.XXX stats. What is wrong with this ?
> >
> > In this case one lost pkg is accounted for twice, once on eth0.1 and
> > once more on eth0.1.1. Note that eth0.1.1 is stacked on
> > top of eth0.1
> >
> > I would at least expect eth0 to also account lost pkgs too.
> > I was confused by the current accounting as I knew that
> > the underlying HW I/F should be the only I/F that could
> > drop pkgs.
>
> In case of NET_XMIT_CN, the packet is dropped by the qdisc before
> it reaches eth0, so its only accounted on the upper devices.

hmm, I am afraid I don't follow this. Why would a pkg be dropped before
it reaches eth0?

>
> >> If you want to avoid this, just add queues to your vlans
> >>
> >> ip link add link eth0 eth0.103 txqueuelen 100 type vlan id 103
> >
> >>From memory now, but that didn't help. Still accounts pgks
> > as described. Why would where to account pkgs be affected by
> > queue or no queue?
>
> If a queue is used on the vlan device, it will queue the packet
> until the lower device is able to transmit it (unless its own
> queue overflows).

And if a pkg is is lost this also changes where to account dropped?
I don't understand this. The queue may prevent pkg loss to some degree
but I don't get why a queue!=0 would change on which interface to
account for lost pkg's.

      Jocke

