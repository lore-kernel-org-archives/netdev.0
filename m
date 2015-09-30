From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: DSA driver - how to glue to a PCI based NIC's mdio?
Date: Wed, 30 Sep 2015 14:27:19 -0700
Message-ID: <CAJ+vNU2SUpsQ+7dwPfR6EHVofpvVFF42KO=YUDaarLaDwWvXFw@mail.gmail.com>
References: <CAJ+vNU2rf0r9V3DfF1-=hpEhdqxkDHz-LmHWOJqscLdsw2EDEA@mail.gmail.com>
	<20150930211210.GD20219@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:32848 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbbI3V1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 17:27:20 -0400
Received: by obbbh8 with SMTP id bh8so42563476obb.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 14:27:19 -0700 (PDT)
In-Reply-To: <20150930211210.GD20219@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2015 at 2:12 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Sep 30, 2015 at 01:44:52PM -0700, Tim Harvey wrote:
>> Greetings,
>>
>> I'm working on adding DSA support for a PCIe expansion card (designed
>> by us) that has common PCIe NIC connected via its mii-bus to a Marvell
>> MV88E6171. Because the NIC is a PCIe device, it has no device-tree
>> representation of its NIC or its mdio bus, but does register its mdio
>> bus with Linux.
>
> It is possible to represent PCIe devices in device tree. Take a look
> at ePAPR. Is the PCIe host in DT?

It is possible to represent PCI devices in device-tree however not in
a dynamic or plug-able fashion - they have to be nested per bus/slot
which defeats the purpose of dynamic enumeration.

>
>> Perhaps the right approach is to program the NIC's EEPROM on our board
>> with a PCI_ID/DEVICE_ID of ours, add support for those ID's to the
>> NIC's driver, and within the NIC's driver create and register dsa
>> platform device when our ID is encountered?
>
> This sounds sensible. But i doubt you can add your DSA platform
> information to the NIC's device driver. Better would be to have a
> small shim driver which is loaded on your PCI_ID/DEVICE_ID. That would
> instantiate the NIC driver, and insert a DSA platform device.

I was thinking of this as well, but then I would still need that shim
to know the netdevice that the driver I'm shimming creates so I can't
figure a way to do it without touching the PCI driver.

Tim
