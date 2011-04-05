From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: Netxen packet loss with VLANs and LRO (was: [PATCH] netxen:
	fix LRO disable warning)
Date: Tue, 5 Apr 2011 14:41:58 +0200
Message-ID: <20110405124158.GA28382@torres.zugschlus.de>
References: <1300703828-6291-1-git-send-email-amit.salecha@qlogic.com> <20110403190555.GA16196@torres.zugschlus.de> <99737F4847ED0A48AECC9F4A1974A4B80FD10E8E3C@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:42336 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558Ab1DEMl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 08:41:59 -0400
Content-Disposition: inline
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8E3C@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2011 at 12:38:11AM -0500, Amit Salecha wrote:
> > On Mon, Mar 21, 2011 at 03:37:08AM -0700, Amit Kumar Salecha wrote:
> > > netxen_nic_set_flags() rejects data if other flag than ETH_FLAG_LRO
> > is set.
> > > Driver also supports NETIF_F_HW_VLAN_TX.
> > > Now compare data with ethtool_op_get_flags(), to get all supported
> > features.
> >
> > Could that be the cause for packet loss on kernel 2.6.38.2 if:
> >
> >   - receiving card is NX3031 [4040:0100]
> >   - frames are received with VLAN tags
> >   - large received offload is on.
> 
> If ip_forwarding or routing is enable ....then you may see packet loss.

The box is intended to route, so disabling routing is
contraproductive. I just would like to download software updates to
the box with decent speed as well.

> > Packet Loss of this kind is noticed when doing TCP data transfers
> > towards the host with the Netxen Interface and the TCP session is
> > terminated on the Netxen host itself. TCP sessions routed through the
> > Netxen host are not affected.
> >
> > My ethtool doesn't allow me to influence the LRO setting alone - it is
> > disabled when I set rx off but doesn't come on again when rx is set to
> > on again. So, ethtool -K rx off, ethtool -K rx on fixes the issue.
> >
> If rx csum is disabled, LRO will be disable. LRO won't be enabled automatically if you enable rx csum.
> You need to explicitly enable LRO.

Explicitly enabling LRO does not work ("invalid argument", if I recall
correctly).

> > Is this a known bug, maybe with an available patch?
> >
> You need to retest with this patch
> http://patchwork.ozlabs.org/patch/88060/. This patch got applied
> instead of mine.

Will that patch fix the behavior of the interface regarding the packet
loss, or only its connection to ethtool?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
