From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: [PATCH 09/15] tg3: Allow WOL for phylib controlled Broadcom phys
Date: Mon, 3 Nov 2008 17:09:34 -0600
Message-ID: <2acbd3e40811031509q3d3005e5g9fedd842a1d08a52@mail.gmail.com>
References: <1225751626.6190@xw6200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Michael Chan" <mchan@broadcom.com>, andy@greyhouse.net
To: "Matt Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:36909 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbYKCXJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 18:09:34 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2803168wfd.4
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 15:09:34 -0800 (PST)
In-Reply-To: <1225751626.6190@xw6200>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 3, 2008 at 4:13 AM, Matt Carlson <mcarlson@broadcom.com> wrote:
> This patch allows WOL to be enabled for Broadcom phys under phylib
> control.  The only exception is the AC131, which has a completely
> different register set.
>
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Code to enable WOL sounds like the sort of thing we'd want in the PHY
driver itself, rather than a manual setup done from the NIC driver.
Clearly, we need support for WOL on both in order for it to work,
though, so I can see two solutions off the top of my head:

1) phy_connect() allows for passing in flags.  Maybe we should create
one for WOL, and have the config_init() functions for the Broadcom
PHYs check that, and set it up.

2) The appropriate code can register a phy_fixup, which will be
invoked whenever the PHY is initialized.  The fixup can be restricted
based on PHY ID and address.

It seems to me that WOL support is probably a common desire, so we
should either always enable it, or provide generic infrastructure for
enabling it, so that your driver doesn't need to know what PHY it is
connecting to.

Andy
