From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Mon, 8 May 2017 14:38:52 +0200
Message-ID: <20170508123852.GI27709@lunn.ch>
References: <58F9FD64.80506@aoifes.com>
 <20170425082741.59428876@xeon-e3>
 <5901DE9F.1070005@aoifes.com>
 <20170427130450.GL17172@lunn.ch>
 <59032D8B.1010801@aoifes.com>
 <20170428122259.GH13231@lunn.ch>
 <59105EA3.9030203@aoifes.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Rafa Corvillo <rafael.corvillo@aoifes.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52779 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750853AbdEHMiy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 08:38:54 -0400
Content-Disposition: inline
In-Reply-To: <59105EA3.9030203@aoifes.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >static unsigned sky2_get_rx_threshold(struct sky2_port *sky2)
> >{
> >         unsigned size;
> >
> >         /* Space needed for frame data + headers rounded up */
> >         size = roundup(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8);
> >
> >         /* Stopping point for hardware truncation */
> >         return (size - 8) / sizeof(u32);
> >}
> >
> >This is not going to be big enough for a frame with a DSA header.
> >
> 
> Then, would be a good fix add 8 bytes to the size variable in this function?

Yes. Also look at the transmit code, is there again a limit based on
the MTU.

> Settings for marvell:
>         Supported ports: [ TP ]
>         Supported link modes:   10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Half 1000baseT/Full
>         Supported pause frame use: No
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Half 1000baseT/Full
>         Advertised pause frame use: No
>         Advertised auto-negotiation: No
>         Speed: 1000Mb/s
>         Duplex: Full
>         Port: Twisted Pair
>         PHYAD: 0
>         Transceiver: internal
>         Auto-negotiation: on
>         MDI-X: Unknown
>         Supports Wake-on: pg
>         Wake-on: d
>         Current message level: 0x000000ff (255)
>                                drv probe link timer ifdown ifup
> rx_err tx_err
>         Link detected: yes
> 

So this suggests there is a real PHY there, and it is
auto-negotiating.

What we cannot see is the status for the PHY it connects to. But since
this PHY has established a link, the other PHY is probably O.K. It is
just a bit unsafe, since you are relying on reset behaviour. There is
nothing in software configuring the second PHY to make it
auto-negotiate.

	Andrew
