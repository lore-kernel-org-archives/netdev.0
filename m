From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 1/2] net: macb: Add MDIO driver for accessing multiple
 PHY devices
Date: Tue, 29 Nov 2016 09:41:36 +0530
Message-ID: <CAFcVECJ-wNwmuVWb4AAL19UQtrB70+S6W0X+jvdOzkrR0ggJBg@mail.gmail.com>
References: <1480326554-6041-1-git-send-email-harinik@xilinx.com> <20161128163356.GJ17704@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Harini Katakam <harini.katakam@xilinx.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>, davem@davemloft.net,
        Rob Herring <robh+dt@kernel.org>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        "ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
        Kumar Gala <galak@codeaurora.org>,
        Boris Brezillon <boris.brezillon@free-electrons.com>,
        alexandre.belloni@free-electrons.com, netdev@vger.kernel.org,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "michals@xilinx.com" <michals@xilinx.com>,
        Punnaiah Choudary Kalluri <punnaia@xilinx.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33464 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752561AbcK2ELi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 23:11:38 -0500
In-Reply-To: <20161128163356.GJ17704@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Mon, Nov 28, 2016 at 10:03 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Mon, Nov 28, 2016 at 03:19:14PM +0530, Harini Katakam wrote:
>> This patch is to add support for the hardware with multiple ethernet
>> MAC controllers and a single MDIO bus connected to multiple PHY devices.
>> MDIO lines are connected to any one of the ethernet MAC controllers and
>> all the PHY devices will be accessed using the PHY maintenance interface
>> in that MAC controller. This handling along with PHY functionality is
>> moved to macb_mdio.c
>>
>> Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
>> Signed-off-by: Harini Katakam <harinik@xilinx.com>
>> ---
>>  drivers/net/ethernet/cadence/Makefile    |   2 +-
>>  drivers/net/ethernet/cadence/macb.c      | 169 +++-----------------
>>  drivers/net/ethernet/cadence/macb.h      |   2 +
>>  drivers/net/ethernet/cadence/macb_mdio.c | 266 +++++++++++++++++++++++++++++++
>>  4 files changed, 294 insertions(+), 145 deletions(-)
>>  create mode 100644 drivers/net/ethernet/cadence/macb_mdio.c
>>
<snip>
>> +     bus->irq = devm_kzalloc(&pdev->dev, sizeof(int) * PHY_MAX_ADDR,
>> +                             GFP_KERNEL);
>
> This looks wrong, or at least old. It used to be a pointer to an array,
> but it is now an actual array.

Sorry, this was a mistake.
I changed this after rebase, will update in next version.

>
>> +static const struct of_device_id macb_mdio_dt_ids[] = {
>> +     { .compatible = "cdns,macb-mdio" },
>> +
>> +};
>
>
> I've not looked hard enough to know, but can you keep backwards
> compatibility? Won't old device tree's assume the mdio bus is always
> present? Now you need an explicit node otherwise there will not be an
> mdio bus?

Yes, an explicit MDIO bus is required. But I'm not sure
how to maintain backward compatibility (without using this separate
macb_mdio) and have different MACs use the same MDIO bus
with separate PHYs.

Regards,
Harini
