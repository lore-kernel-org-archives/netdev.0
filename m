From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy: marvell: remove conflicting initializer
Date: Mon, 23 Jan 2017 17:28:37 +0100
Message-ID: <20170123162837.GK10895@lunn.ch>
References: <20170123121905.3245589-1-arnd@arndb.de>
 <20170123151941.GG10895@lunn.ch>
 <7242508.n9OCrlbXLu@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>,
        Clemens Gruber <clemens.gruber@pqgruber.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:41760 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750765AbdAWQ2o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 11:28:44 -0500
Content-Disposition: inline
In-Reply-To: <7242508.n9OCrlbXLu@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Great question! I have sent out patches for a couple of actual bugs that
> came from this warning in the past few months.
> 
> I still have a couple of patches that I have not sent out so far,
> I think they are all false-positives, and I have not found a good
> workaround for most of them other than disabling the warning locally.
> 
> Once we get the patches below (or some other workaround) into the
> kernel, we should definitely enable the warning by default.

So it looks like some are from initialising a range of values with
a default value:

[0 ... SH_ETH_MAX_REGISTER_OFFSET - 1] = SH_ETH_OFFSET_INVALID

and then some entries specific values. Maybe the compiler can help out
here? A different warning in this case? And have that at W=1? Could
you ask the gcc folks about this?

Others causes seem like

226 #define DRM_FB_HELPER_DEFAULT_OPS \
227         .fb_check_var   = drm_fb_helper_check_var, \
228         .fb_set_par     = drm_fb_helper_set_par, \
229         .fb_setcmap     = drm_fb_helper_setcmap, \
230         .fb_blank       = drm_fb_helper_blank, \
231         .fb_pan_display = drm_fb_helper_pan_display

static struct fb_ops omap_fb_ops = {
        .owner = THIS_MODULE,
        DRM_FB_HELPER_DEFAULT_OPS,
...
        .fb_pan_display = omap_fbdev_pan_display,

There are at least three drivers which need to replace the
default fb_pan_display. So maybe a different macro?

	Andrew
