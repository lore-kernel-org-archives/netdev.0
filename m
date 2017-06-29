From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: CAN-FD Transceiver Limitations
Date: Thu, 29 Jun 2017 17:41:39 +0200
Message-ID: <20170629154139.GC13221@lunn.ch>
References: <de1f6343-4b28-4a5f-c6df-4e54c09fcce2@ti.com>
 <20170629142142.GF9244@lunn.ch>
 <5d4f2bcf-bd0f-4fa1-5d5a-d7b4a83cbc5e@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de
To: Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5d4f2bcf-bd0f-4fa1-5d5a-d7b4a83cbc5e@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Transceivers for CAN are not apart of any model. Traditional CAN didn't
> have a problem because all transceivers from my understanding supported
> the maximum speed of 1 Mbps defined by the spec. However, with the
> introduction of CAN Flexible Datarate mode it seems that for
> transceivers that supported CAN-FD the maximum supported speeds vary.

So transceivers are dumb devices, nothing to configure, so no need to
have a driver for them.

> Now that I think of it
> you also can't determine if the transceiver supports CAN-FD in the first
> place. IP that supports CAN-FD is backwards compatible with standard
> CAN. Therefore, its feasible that you may even use a transceiver that
> doesn't support CAN-FD. So I would think something like the below would
> be needed.
> 
> mcan@0 {
> 	...
> 	fixed-transceiver {
> 	      max-canfd-speed = <2000>
> 	};
> 	...
> };

Are there likely to be other transceiver properties? Adding a subnode
may not make sense if this is going to be the only property.

Also, 2KHz is not very fast :-)

Taking a quick look in Documentation/devicetree/bindings/net/can, it
seems a bit of a wild west. No standardization, no central binding
which CAN drivers are expected to support, etc. This sounds like a
generic problem, not an mcan problem. So document this property
centrally, implement the parsing of it centrally, etc, to encourage
other CAN drivers to use it, rather than re-invent the wheel.

	   Andrew
