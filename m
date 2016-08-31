From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Wed, 31 Aug 2016 15:46:27 -0500
Message-ID: <CAL_Jsq+BtwBtB7Vd8HB+vhucfUmn_0bxRRXmyO13GoCM82LgFg@mail.gmail.com>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <20160831150043.GA575@rob-hp-laptop> <57C6F395.1030904@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        linux-arm-msm <linux-arm-msm@vger.kernel.org>,
        Sagar Dharia <sdharia@codeaurora.org>,
        Shanker Donthineni <shankerd@codeaurora.org>,
        Vikram Sethi <vikrams@codeaurora.org>,
        Christopher Covington <cov@codeaurora.org>,
        Gilad Avidov <gavidov@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Mark Langsdorf <mlangsdo@redhat.com>,
        "jcm@redhat.com" <jcm@redhat.com>,
        Andy Gross <agross@codeaurora.org>,
        David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:35432 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753487AbcHaUqx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 16:46:53 -0400
In-Reply-To: <57C6F395.1030904@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 10:11 AM, Timur Tabi <timur@codeaurora.org> wrote:
> Rob Herring wrote:
>
>>> +               internal-phy = <&emac_sgmii>;
>>
>>
>> Can't this use the standard generic phy binding (i.e. 'phys'). It's a
>> bit confusing as there's the ethernet phy binding (phy-handle) and the
>> generic one.
>
>
> It's not a generic phy.  It's a funky "internal phy" that differs among
> SOCs.  I call it the internal phy, but I could use another name. Internally,
> some people call it the "sgmii phy", but I don't think that's accurate.

Funky internal PHYs are precisely the types of PHYs this binding is
for. It is generic in that the type is not defined. It can be USB,
HDMI, DSI, LVDS, etc.

>
> I can call it "emac-phy", but I don't know if that's any better.
>
>>> +               phy-handle = <&phy0>;
>>
>>
>> This is bit redundant as the phy is the child node. I guess if you had
>> multiple devices on the mdio bus you would need it. I'd drop it if you
>> don't envision needing it and the kernel doesn't require it.
>
>
> That's what I thought to, but without it, of_phy_find_device() won't work.
> I need a pointer to the phy node, and I use of_parse_phandle() to get it:
>
>         struct device_node *phy_np;
>
>         ret = of_mdiobus_register(mii_bus, np);
>         if (ret) {
>                 dev_err(&pdev->dev, "could not register mdio bus\n");
>                 return ret;
>         }
>
>         phy_np = of_parse_phandle(np, "phy-handle", 0);

You can just as easily find the child node called ethernet-phy.

>         adpt->phydev = of_phy_find_device(phy_np);
>
>>> +
>>> +               #address-cells = <1>;
>>> +               #size-cells = <0>;
>>> +               phy0: ethernet-phy@0 {
>>
>>
>> It's just an example, but don't we require compatible strings for phys
>> now?
>
>
> Nope. I had a compatible property, but it broke of_mdiobus_child_is_phy().
> I don't want to specify why kind of phy it is.  I want to let phylib figure
> it out.

Okay, I'll defer to the mdio folks.

Rob
