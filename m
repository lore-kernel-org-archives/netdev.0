From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2] [v4] net: emac: emac gigabit ethernet controller
 driver
Date: Fri, 15 Apr 2016 09:44:33 -0700
Message-ID: <20160415164433.GV391@tuxbot>
References: <1460570393-19838-1-git-send-email-timur@codeaurora.org>
 <570EC541.6080603@gmail.com>
 <570FFB6B.5060305@codeaurora.org>
 <57100962.40404@gmail.com>
 <571012E6.6050303@codeaurora.org>
 <57102920.7000104@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vikram Sethi <vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Shanker Donthineni <shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Greg Kroah-Hartman <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	andrew-g2DYL2Zd6BY@public.gmane.org, Mark Langsdorf <mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Jon Masters <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Gross <agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57102920.7000104-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu 14 Apr 16:34 PDT 2016, Timur Tabi wrote:

[..]
> So I think the solution is to create a device tree (and ACPI) property that
> holds the mask.
> 
> 	dma-mask = <0 0xffffffff>;
> 
> or
> 
> 	dma-mask = <0xffffffff 0xffffffff>;
> 
> The driver will then do this:
> 
> 	u64 dma_mask;
> 	device_property_read_u64(&pdev->dev, "dma-mask", &dma_mask);
> 	dma_coerce_mask_and_coherent(&pdev->dev, dma_mask);
> 
> What I'm not sure yet is whether I should call
> dma_coerce_mask_and_coherent() or dma_set_coherent_mask().
> 

For platform devices being populated via from DT you will pass:
of_platform_bus_create()
  of_platform_device_create_pdata()
    of_dma_configure()

Which calls of_dma_get_range() to acquire this information from the
dma-ranges property and set up the dma ops and properties.

Regards,
Bjorn
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
