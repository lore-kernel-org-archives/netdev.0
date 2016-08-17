From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 17:32:23 -0500
Message-ID: <57B4E5F7.9040500@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
 <57B31780.5030106@codeaurora.org>
 <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
 <57B3878D.1000805@codeaurora.org>
 <ff901f77-2177-52a7-2464-2f61495f91be@gmail.com>
 <57B4C6EE.3080903@codeaurora.org>
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
In-Reply-To: <57B4C6EE.3080903-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Timur Tabi wrote:
>>
>> Nothing prevents you from detailing in ACPI or DT sub-components of a
>> larger HW block, if there is such a desire, but just make it in a way
>> that it looks like what would be done for e.g: separate discrete parts,
>> only the parenting of nodes would change.
>
> So instead of just having a single property, instead create a child node
> just for the SGMII phy, with its own compatible string and various other
> properties (like interrupt and base register)?  That's not a bad idea.

I need help getting this to work.

	emac0: ethernet@38800000 {
		compatible = "qcom,qdf2432-emac";
		reg-names = "base", "csr";
                 reg = <0x0 0x38800000 0x0 0x10000 >,
                         <0x0 0x38816000 0x0 0x1000>,
                         <0x0 0x3881C000 0x0 0x4000>;
		interrupts = <0 0x100 0 0 0x104 0>;
		interrupt-names = "core0", "sgmii";

		sgmii-handle = <&emac_sgmii>;
		phy-handle = <&phy0>;

		#address-cells = <1>;
		#size-cells = <0>;
		phy0: ethernet-phy@4 {
			reg = <4>;
		};
	};

	emac_sgmii: ethernet-phy@410400 {
		compatible = "qcom,qdf2432-emac-phy";
		reg = <0x0 0x00410400 0x0 0x100>;
		interrupts = <0 0x104 0>;
	};

When my driver probes, the platform_device object points to the emac0 
node, as always.

How do I parse the emac_sgmii node?  How do I get functions like 
platform_get_resource() to work?  How do I create a new platform_device 
object that points to the emac_sgmii node?

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
