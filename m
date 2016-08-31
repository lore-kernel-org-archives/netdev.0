From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Wed, 31 Aug 2016 16:00:18 -0500
Message-ID: <57C74562.3050203@codeaurora.org>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <20160831150043.GA575@rob-hp-laptop> <57C6F395.1030904@codeaurora.org>
 <CAL_Jsq+BtwBtB7Vd8HB+vhucfUmn_0bxRRXmyO13GoCM82LgFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-msm <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sagar Dharia <sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Shanker Donthineni <shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Vikram Sethi <vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Mark Langsdorf <mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Andy Gross <agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_Jsq+BtwBtB7Vd8HB+vhucfUmn_0bxRRXmyO13GoCM82LgFg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rob Herring wrote:
>> It's not a generic phy.  It's a funky "internal phy" that differs among
>> >SOCs.  I call it the internal phy, but I could use another name. Internally,
>> >some people call it the "sgmii phy", but I don't think that's accurate.

> Funky internal PHYs are precisely the types of PHYs this binding is
> for. It is generic in that the type is not defined. It can be USB,
> HDMI, DSI, LVDS, etc.

I don't understand what you're getting at.  There are two IP blocks that 
have a private interconnect.  One is the MAC, and the other is an 
internal PHY, but the driver programs them as one device.

If you want me to make some kind of change, you're going to have to be 
more specific.

>> >That's what I thought to, but without it, of_phy_find_device() won't work.
>> >I need a pointer to the phy node, and I use of_parse_phandle() to get it:
>> >
>> >         struct device_node *phy_np;
>> >
>> >         ret = of_mdiobus_register(mii_bus, np);
>> >         if (ret) {
>> >                 dev_err(&pdev->dev, "could not register mdio bus\n");
>> >                 return ret;
>> >         }
>> >
>> >         phy_np = of_parse_phandle(np, "phy-handle", 0);

> You can just as easily find the child node called ethernet-phy.

As Andrew pointed out, using phy-handle allows me to place the phy node 
anywhere.

I've already made changes to this design, and every change has raised 
objections.  I don't see anything wrong with phy-handle.  A lot of 
drivers use it.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
