From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Thu, 1 Sep 2016 17:49:13 -0500
Message-ID: <CAL_Jsq+75RJOCFUrUV43457kQ4o5oRjRhLLT2yGzTFfYhSESfg@mail.gmail.com>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <20160831150043.GA575@rob-hp-laptop> <57C6F395.1030904@codeaurora.org>
 <CAL_Jsq+BtwBtB7Vd8HB+vhucfUmn_0bxRRXmyO13GoCM82LgFg@mail.gmail.com> <57C74562.3050203@codeaurora.org>
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
Received: from mail.kernel.org ([198.145.29.136]:36890 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752941AbcIAWtj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 18:49:39 -0400
In-Reply-To: <57C74562.3050203@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 4:00 PM, Timur Tabi <timur@codeaurora.org> wrote:
> Rob Herring wrote:
>>>
>>> It's not a generic phy.  It's a funky "internal phy" that differs among
>>> >SOCs.  I call it the internal phy, but I could use another name.
>>> > Internally,
>>> >some people call it the "sgmii phy", but I don't think that's accurate.
>
>
>> Funky internal PHYs are precisely the types of PHYs this binding is
>> for. It is generic in that the type is not defined. It can be USB,
>> HDMI, DSI, LVDS, etc.
>
>
> I don't understand what you're getting at.  There are two IP blocks that
> have a private interconnect.  One is the MAC, and the other is an internal
> PHY, but the driver programs them as one device.
>
> If you want me to make some kind of change, you're going to have to be more
> specific.

The change would simply be use "phys" for the property here and add
#phy-cells to the phy node. See bindings/phy/phy-binding.txt.

And just because you just the phy binding, that doesn't mean you have
to use the generic phy framework in the kernel. I'm not suggesting you
need to. That could change in time as this becomes more common (i.e.
with 10G).

>>> >That's what I thought to, but without it, of_phy_find_device() won't
>>> > work.
>>> >I need a pointer to the phy node, and I use of_parse_phandle() to get
>>> > it:
>>> >
>>> >         struct device_node *phy_np;
>>> >
>>> >         ret = of_mdiobus_register(mii_bus, np);
>>> >         if (ret) {
>>> >                 dev_err(&pdev->dev, "could not register mdio bus\n");
>>> >                 return ret;
>>> >         }
>>> >
>>> >         phy_np = of_parse_phandle(np, "phy-handle", 0);
>
>
>> You can just as easily find the child node called ethernet-phy.
>
>
> As Andrew pointed out, using phy-handle allows me to place the phy node
> anywhere.

But you can't because the binding says (or should say) it is a child node.

> I've already made changes to this design, and every change has raised
> objections.  I don't see anything wrong with phy-handle.  A lot of drivers
> use it.

You said it wouldn't work. I'm only pointing out that that is not
true. As I said to begin with, if everything else is using it, then
it's fine.

Rob
