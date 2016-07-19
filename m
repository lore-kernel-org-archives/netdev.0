From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v0 00/10] Convert Netgear WNR854T to devicetree
Date: Tue, 19 Jul 2016 16:16:40 +0200
Message-ID: <20160719141640.GZ31103@lunn.ch>
References: <1468679348-10522-1-git-send-email-jm@lentin.co.uk>
 <20160716205304.GA5075@lunn.ch>
 <alpine.DEB.2.11.1607171043100.19980@marmot.wormnet.eu>
 <20160717153338.GA13611@lunn.ch>
 <alpine.DEB.2.11.1607190933590.19980@marmot.wormnet.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Jamie Lentin <jm@lentin.co.uk>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45629 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753551AbcGSOQu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 10:16:50 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1607190933590.19980@marmot.wormnet.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Reducing the Cc: list a bit to networking people]

> Okay. Frames sent from the port are EDSA-tagged (which isn't exactly
> surprising), but I'm yet to see the switch receive 0xdada frames.
> Even with the net-next branch which uses DSA_TAG_PROTO_EDSA for all
> chip types.
> 
> However, the ethertype is reflecting the port:-
> 
> lan1/5 : ethertype Unknown (0xc028), length 176:
> lan2/7 : ethertype Unknown (0xc038), length 176:
> lan3/0 : ethertype Unknown (0xc000), length 176:
> lan4/1 : ethertype Unknown (0xc008), length 176:
> wan/2  : ethertype Unknown (0xc010), length 176:

O.K, we broke it :-(

The 6185 does not support EDSA, only DSA.

Vivien, this is going to cause us problems. We need two different
dsa_switch_driver structures, one for EDSA capable devices, and one
for those which are not.

Or we do something more radical, like add a driver callback to return
the tagging protocol, rather than hard code it in the structure? We
can then use a capability flag.

    Andrew
