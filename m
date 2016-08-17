From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 13:07:25 -0700
Message-ID: <ff901f77-2177-52a7-2464-2f61495f91be@gmail.com>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
 <57B31780.5030106@codeaurora.org>
 <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
 <57B3878D.1000805@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
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
	"Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Al Stone <al.stone-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57B3878D.1000805-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/16/2016 02:37 PM, Timur Tabi wrote:
> Al Stone wrote:
>> Does the ACPI portion of the driver*have*  to know about the PHY?  In
>> general,
>> the ACPI assumption on ARM [**] is that those have all been set up
>> before we
>> get to the kernel.  So, does it need to be visible to the ACPI part of
>> the
>> driver at all?
> 
> Yes, the driver supports both "v1" and "v2" of the PHY, and it has code
> like this:
> 
>     if (adpt->phy.version == 2)
>         emac_sgmii_init_v2(adpt);
>     else
>         emac_sgmii_init_v1(adpt);
> 
> The question, how should adpt->phy.version be initialized on device tree
> and ACPI platforms?
> 
> The reason why this is confusing is because there are conflicting
> perspectives of this "internal PHY".  It both is and is not part of the
> EMAC.  It is a separate block in the chip, and can be replaced with
> other SGMII blocks, and in the future there will be a "v3" and maybe a
> "v4" or who knows what.  In fact, maybe using version numbers is
> inappropriate and we'll need to use vendor names or something.

If it has self identification, and the MAC is capable of knowing what
kind of PHY it is internally bundled with, why does it matter to
represent that specific piece of information in Device Tree or ACPI?

> 
> The problem is that the internal PHY has mechanism for
> self-identification.  There is no ACPI or device tree node for it. There
> is no register you can query to see if it's there or what version it
> is.  The MAC part of the EMAC has no knowledge of the PHY part.  The
> driver just has to know it's there.

Nothing prevents you from detailing in ACPI or DT sub-components of a
larger HW block, if there is such a desire, but just make it in a way
that it looks like what would be done for e.g: separate discrete parts,
only the parenting of nodes would change.

> 
> This is why I'm advocating a separate property (DT and ACPI) to identify
> the internal PHY
> 
> The truth is that I don't really care HOW it's done, and as long as we
> come to a consensus soon.  I want my driver to be merged into 4.9.
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
