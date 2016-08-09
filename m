From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 9 Aug 2016 14:34:00 -0500
Message-ID: <57AA3028.2080506@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <9ebb6cb7-c793-cd76-5283-c9a659d0398f@gmx.de>
 <57AA2001.2010904@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Lino Sanfilippo <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57AA2001.2010904-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Timur Tabi wrote:
> I used to work on PowerPC, so I respect making things work for both
> endians.  However, even I think that this is overkill for my driver.
> First, there's no way this driver will ever be used on a big-endian
> system.  Second, I'm pretty sure there are lots of places that would
> need cpu_to_le32() in order to make this driver big-endian compatible.
> It would be a huge mess.
>
> #define TPD_BUFFER_ADDR_H_SET(tpd, val)    BITS_SET((tpd)->word[3], 18,
> 30, val)
>
> This macros sets specific bits based on the definition of the register.
>   I could change it to this:
>
> #define TPD_BUFFER_ADDR_H_SET(tpd, val) BITS_SET((tpd)->word[3], 18, 30,
> cpu_to_le32(val))
>
> But I honestly don't see what good that will do.  There are still
> thousands of other places that assume little-endian.

Ok, so I took another look at this, and even though I still think that 
it's useless, it seems to be much less difficult to implement than I 
initially thought.

I think all I need to do is to modify the BITS_GET() and BITS_SET() 
macros in emac-mac.h, as well as any of the RRD_xxx and TPD_xxx macros 
that do not use BITS_GET() or BITS_SET().  This is a minor change which 
I will implement in v8 of the patch.

Every other hardware access uses readl/writel, which is already endian-safe.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
