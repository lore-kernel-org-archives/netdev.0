From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: VLAN I/F's and TX queue.
Date: Sun, 16 May 2010 16:22:51 +0200
Message-ID: <OFD8612D58.D91B0A31-ONC1257725.004CE192-C1257725.004EFF12@transmode.se>
References: <OF803EE436.793B95D8-ONC125771C.003295C9-C125771C.00341AFF@transmode.se>	<4BE8191C.8020302@trash.net>
	<OFC83B46CB.0E764A8E-ONC125771F.005109E4-C125771F.00518338@transmode.se> <20100516.004041.73702151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: eric.dumazet@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:47824 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754584Ab0EPO1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 May 2010 10:27:25 -0400
In-Reply-To: <20100516.004041.73702151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller <davem@davemloft.net> wrote on 2010/05/16 09:40:41:
>
> From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Date: Mon, 10 May 2010 16:50:20 +0200
>
> > Patrick McHardy <kaber@trash.net> wrote on 2010/05/10 16:33:00:
> >>
> >> Joakim Tjernlund wrote:
> >> > Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/05/07 10:53:23:
> >> >>> 3) I would expect lost pkgs to be accounted on eth0 instead of
> >> >>>    the VLAN interface(s) since that is where the pkg is lost, why
> >> >>>    isn't it so?
> >> >> You try to send packets on eth0.XXX, some are dropped, and accounted for
> >> >> on eth0.XXX stats. What is wrong with this ?
> >> >
> >> > In this case one lost pkg is accounted for twice, once on eth0.1 and
> >> > once more on eth0.1.1. Note that eth0.1.1 is stacked on
> >> > top of eth0.1
> >> >
> >> > I would at least expect eth0 to also account lost pkgs too.
> >> > I was confused by the current accounting as I knew that
> >> > the underlying HW I/F should be the only I/F that could
> >> > drop pkgs.
> >>
> >> In case of NET_XMIT_CN, the packet is dropped by the qdisc before
> >> it reaches eth0, so its only accounted on the upper devices.
> >
> > hmm, I am afraid I don't follow this. Why would a pkg be dropped before
> > it reaches eth0?
>
> Because we have packet schedulers that sit before the device transmit
> happens, and those packet schedulers enforce limits based upon
> classification results or other criteria, and if those limits are
> exceeded packets are droppers and NET_XMIT_CN is returned back up into
> the transmit path of the networking stack.

OK, but what I don't get is if pgks are dropped as soon as the underlying
device cannot handle the pkg directly(returns !NETDEV_TX_OK or stops the queue)?
Are !NETDEV_TX_OK and stopping the queue handled differently by upper layers?
I would have expected the pkg be added to the TX queue and transmitted somewhat later.
If not, what is the TX queue for?

>
> The device never sees that packet get submitted to it's ->ndo_start_xmit()
> routine, and this is entirely intentional.  And it is entirely intentional
> that NET_XMIT_CN gets passed up into the caller, where protocols such as
> TCP can key off this information to make congestion control decisions.

In this case it gets passed up to the VLAN driver, should the VLAN driver
do something else to use the TX queue?

      Jocke

