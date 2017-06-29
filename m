From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: CAN-FD Transceiver Limitations
Date: Thu, 29 Jun 2017 19:19:00 +0200
Message-ID: <20170629171900.GA17008@lunn.ch>
References: <de1f6343-4b28-4a5f-c6df-4e54c09fcce2@ti.com>
 <20170629142142.GF9244@lunn.ch>
 <5d4f2bcf-bd0f-4fa1-5d5a-d7b4a83cbc5e@ti.com>
 <20170629154139.GC13221@lunn.ch>
 <c0d3d772-6939-d22c-b954-3ba6486a9ede@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de, devicetree@vger.kernel.org
To: Franklin S Cooper Jr <fcooper@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39532 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753175AbdF2RTG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 13:19:06 -0400
Content-Disposition: inline
In-Reply-To: <c0d3d772-6939-d22c-b954-3ba6486a9ede@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Also I agree that attempting to make this optional property/subnode
> generic to all of CAN would be preferable. Another not sure if its
> feasible yet without standardization being first forced across all CAN
> drivers.

It should be. All you need to do is add an
of_get_can_maxspeed(struct device_node *np)
for drivers to call.

If it finds the property, return its value, otherwise return the
standardised 1Mbps.

And you probably want to do the verify in can_changelink(), by adding
the max speed into the can_priv structure somewhere.

    Andrew
