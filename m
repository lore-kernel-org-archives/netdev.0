From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Wed, 31 Aug 2016 10:11:17 -0500
Message-ID: <57C6F395.1030904@codeaurora.org>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
 <20160831150043.GA575@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160831150043.GA575@rob-hp-laptop>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rob Herring wrote:

>> +		internal-phy = <&emac_sgmii>;
>
> Can't this use the standard generic phy binding (i.e. 'phys'). It's a
> bit confusing as there's the ethernet phy binding (phy-handle) and the
> generic one.

It's not a generic phy.  It's a funky "internal phy" that differs among 
SOCs.  I call it the internal phy, but I could use another name. 
Internally, some people call it the "sgmii phy", but I don't think 
that's accurate.

I can call it "emac-phy", but I don't know if that's any better.

>> +		phy-handle = <&phy0>;
>
> This is bit redundant as the phy is the child node. I guess if you had
> multiple devices on the mdio bus you would need it. I'd drop it if you
> don't envision needing it and the kernel doesn't require it.

That's what I thought to, but without it, of_phy_find_device() won't 
work.  I need a pointer to the phy node, and I use of_parse_phandle() to 
get it:

	struct device_node *phy_np;

	ret = of_mdiobus_register(mii_bus, np);
	if (ret) {
		dev_err(&pdev->dev, "could not register mdio bus\n");
		return ret;
	}

	phy_np = of_parse_phandle(np, "phy-handle", 0);
	adpt->phydev = of_phy_find_device(phy_np);

>> +
>> +		#address-cells = <1>;
>> +		#size-cells = <0>;
>> +		phy0: ethernet-phy@0 {
>
> It's just an example, but don't we require compatible strings for phys
> now?

Nope. I had a compatible property, but it broke 
of_mdiobus_child_is_phy().  I don't want to specify why kind of phy it 
is.  I want to let phylib figure it out.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
