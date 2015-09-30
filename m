From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA driver - how to glue to a PCI based NIC's mdio?
Date: Wed, 30 Sep 2015 23:12:10 +0200
Message-ID: <20150930211210.GD20219@lunn.ch>
References: <CAJ+vNU2rf0r9V3DfF1-=hpEhdqxkDHz-LmHWOJqscLdsw2EDEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38165 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754151AbbI3VMM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 17:12:12 -0400
Content-Disposition: inline
In-Reply-To: <CAJ+vNU2rf0r9V3DfF1-=hpEhdqxkDHz-LmHWOJqscLdsw2EDEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 01:44:52PM -0700, Tim Harvey wrote:
> Greetings,
> 
> I'm working on adding DSA support for a PCIe expansion card (designed
> by us) that has common PCIe NIC connected via its mii-bus to a Marvell
> MV88E6171. Because the NIC is a PCIe device, it has no device-tree
> representation of its NIC or its mdio bus, but does register its mdio
> bus with Linux.

It is possible to represent PCIe devices in device tree. Take a look
at ePAPR. Is the PCIe host in DT?

> Perhaps the right approach is to program the NIC's EEPROM on our board
> with a PCI_ID/DEVICE_ID of ours, add support for those ID's to the
> NIC's driver, and within the NIC's driver create and register dsa
> platform device when our ID is encountered?

This sounds sensible. But i doubt you can add your DSA platform
information to the NIC's device driver. Better would be to have a
small shim driver which is loaded on your PCI_ID/DEVICE_ID. That would
instantiate the NIC driver, and insert a DSA platform device.

    Andrew
