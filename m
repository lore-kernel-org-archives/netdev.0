From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next 0/3] net: bridge: Allow CPU port configuration
Date: Tue, 22 Nov 2016 18:48:29 +0100
Message-ID: <20161122174829.GD14947@lunn.ch>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
 <20161122174140.2ly226dcxkv23nlo@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        davem@davemloft.net, bridge@lists.linux-foundation.org,
        stephen@networkplumber.org, vivien.didelot@savoirfairelinux.com,
        jiri@mellanox.com, idosch@mellanox.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48763 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933750AbcKVRse (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Nov 2016 12:48:34 -0500
Content-Disposition: inline
In-Reply-To: <20161122174140.2ly226dcxkv23nlo@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ido
 
> First of all, I want to be sure that when we say "CPU port", we're
> talking about the same thing. In mlxsw, the CPU port is a pipe between
> the device and the host, through which all packets trapped to the host
> go through. So, when a packet is trapped, the driver reads its Rx
> descriptor, checks through which port it ingressed, resolves its netdev,
> sets skb->dev accordingly and injects it to the Rx path via
> netif_receive_skb(). The CPU port itself isn't represented using a
> netdev.

With DSA, we have a real physical ethernet network interface for the
'cpu' port. It connects to one of the ports of the switch. Frames on
this interface have an extra header, indicating which switch port it
came from, and we do a similar resolving it to a slave netdev, strip
of the header and injecting it into the receiver path via
netif_receive_skb().

	Andrew
