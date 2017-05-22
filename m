From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] net: fec: add post PHY reset delay DT property
Date: Mon, 22 May 2017 16:43:01 +0200
Message-ID: <20170522144301.GE29447@lunn.ch>
References: <20170522091517.6857-1-quentin.schulz@free-electrons.com>
 <20170522135705.GB29447@lunn.ch>
 <f667da6e-d300-ec79-cc49-3808d9758a99@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fugang.duan-3arQi8VN3Tc@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
To: Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <f667da6e-d300-ec79-cc49-3808d9758a99-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 22, 2017 at 04:00:47PM +0200, Quentin Schulz wrote:
> Hi Andrew
> 
> On 22/05/2017 15:57, Andrew Lunn wrote:
> > On Mon, May 22, 2017 at 11:15:17AM +0200, Quentin Schulz wrote:
> >> Some PHY require to wait for a bit after the reset GPIO has been
> >> toggled. This adds support for the DT property `phy-reset-post-delay`
> >> which gives the delay in milliseconds to wait after reset.
> >>
> >> If the DT property is not given, no delay is observed. Post reset delay
> >> greater than 1000ms are invalid and are default to 1ms.
> > 
> > Hi Quentin
> > 
> > If it is invalid, please return -EINVAL.
> > 
> 
> Just copying the wording and behavior of phy-reset-duration. Should we
> then change the behavior of phy-reset-duration as well to return -EINVAL
> in that case or I just leave both as is?

No, you cannot change phy-reset-duration. There could be device tree
blobs out in the wild with invalid phy-reset-duration which silently
get converted to 1000ms by the code. You cannot break them.

However, you can prevent new additions which add invalid
phy-reset-post-delay.

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
