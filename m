From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 23:19:23 -0500
Message-ID: <57B5374B.6010805@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
 <57B31780.5030106@codeaurora.org>
 <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
 <57B3878D.1000805@codeaurora.org>
 <ff901f77-2177-52a7-2464-2f61495f91be@gmail.com>
 <57B4C6EE.3080903@codeaurora.org> <57B4E5F7.9040500@codeaurora.org>
 <bec781c6-2db9-02c7-687d-b5d6ee50c129@gmail.com>
 <57B52B17.1080809@codeaurora.org>
 <5CCEFB33-8F93-40D7-BD32-ACDE1CBA586D@gmail.com>
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
	Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>,
	"Abdulhamid, Harb" <harba-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Al Stone <al.stone-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5CCEFB33-8F93-40D7-BD32-ACDE1CBA586D-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:
> The larger issue is that the emac_sgmii node in the form you posted
> is going to be backed by a platform device in Linux while you want a
> PHY device with a reg property that describes a MDIO address
> (#address-cells = 1, #size-cells = 0).

But how do I get the platform device for the emac_sgmii node?  If I 
create an of_device_id ID for it, like this:

static const struct of_device_id emac_dt_match[] = {
	{
		.compatible = "qcom,fsm9900-emac",
	},
	{}
};

static const struct of_device_id emac_sgmii_dt_match[] = {
	{
		.compatible = "qcom,fsm9900-emac-sgmii",
	},
	{}
};

Then the probe function will be called for qcom,fsm9900-emac-sgmii 
separately from qcom,fsm9900-emac, which just confuses things. So I 
can't create emac_sgmii_dt_match.

I know this is standard DT stuff, and I used to do a lot of work on DT 
so maybe I should know this already.  But it seems to me that I need to 
manually create the platform_device for qcom,fsm9900-emac-sgmii.

> IIRC the amd xgbe driver mainline had a similar design but still
> implemented a PHY device anyway although it may not have been using
> Device Tree. It should still be possible to implement a PHY driver
> that you manually register and bind to its device_node pointer such
> that of_phy_find_device and friends still work. You would do this
> from the emac_sgmii platform device driver and parent devices in a
> way that satisfy the PHY device driver lifecycle as well.
>
> Hope this helps.

It doesn't, sorry.  The emac_sgmii is really just another register block 
for the driver to program.  Creating another PHY driver for it doesn't 
really make sense.  It's not on an MDIO bus.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
