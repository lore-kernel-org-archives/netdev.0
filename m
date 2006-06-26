From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Mon, 26 Jun 2006 20:44:25 +0200
Message-ID: <20060626184424.GT1376@postel.suug.ch>
References: <20060626145446.948105000@postel.suug.ch> <20060626145515.769648000@postel.suug.ch> <44A0138F.8050208@trash.net> <20060626.104654.98552111.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:19632 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932641AbWFZSoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 14:44:05 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060626.104654.98552111.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2006-06-26 10:46
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 26 Jun 2006 19:04:15 +0200
> 
> > I know this was discussed before, but I can't remember the
> > exact outcome. Why don't we just unconditionally update iif
> > in netif_receive_skb()?
> 
> Software devices might have interesting semantics that would
> make not setting iif desirable.
> 
> Once you set iif, you can't just undo it because the information
> is lost.
> 
> I also would really prefer to set it unconditionally in
> netif_receive_skb(), but Jamal's concerns in this area are real.
> We really need to evaluate this on a case-by-case basis.

I'm playing with a FIFO device based on Jamal's previous
work to replace the broken IMQ device and provide real
queueing at ingress. A set of VLAN devices could be redirected
to such a FIFO device and let applications bind to it in order
to implement trivial bind(INADDR_ANY) namespaces based on anything
that can be selected by classifiers. This example would benefit
from a conditional iif update (given that the mirred action is
extended to take a flag to steer this) so applications like a
dhcp daemon could use a raw socket on the FIFO device and thus
benefit from the bind namespace but still access the original
interface the packet was received from using pktinfo cmsg.

Maybe silly but the best I could come up with :-)
