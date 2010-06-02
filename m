From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: RE: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
 V5
Date: Wed, 2 Jun 2010 16:20:49 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E70B1836BED@GVW1118EXC.americas.hpqcorp.net>
References: <20100527180813.GA3714@psychotron.redhat.com>
 <20100527130822.02cb1661@nehalam>
 <20100528055154.GB2823@psychotron.redhat.com>
 <20100528061241.GC2823@psychotron.redhat.com>
 <1275030163.2650.3.camel@edumazet-laptop>
 <20100528073345.GD2823@psychotron.redhat.com>
 <20100601082805.1c84b16d@nehalam>
 <20100602075207.GD2603@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Jiri Pirko <jpirko@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:3088 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959Ab0FBQWG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:22:06 -0400
In-Reply-To: <20100602075207.GD2603@psychotron.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
> V5
> 
> What this patch does is it removes two receive frame hooks (for bridge
> and for
> macvlan) from __netif_receive_skb. These are replaced them with a single
> hook for both. It only supports one hook per device because it makes no
> sense to do bridging and macvlan on the same device.
> 
> Then a network driver (of virtual netdev like macvlan or bridge) can
> register
> an rx_handler for needed net device.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I would like to see this being accepted. As mentioned before I would love to be able to support multiple receive frame hooks per device, but I think this is a good start.

I think especially with virtualization coming into Linux and new network virtualization approaches being developed it would be nice to have a more generic function for packet receive handlers to hook into the network stack more cleanly. Current approaches rely on 'misusing' the bridging hook into the kernel, because the packet 'sniffing' hooks (via dev_pack_add()) do not give enough control over packet processing.

