From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Kernel crashes in phy_attach_direct()
Date: Wed, 8 Feb 2017 15:40:29 +0100
Message-ID: <20170208144029.GE10855@lunn.ch>
References: <CAOMZO5C58--W1q+i26-+DBcton0Bk_o3zVfyuumM+Y=OemQ_Aw@mail.gmail.com>
 <20170208142857.GD10855@lunn.ch>
 <CAOMZO5BzLh4az9t=fJkG80GW3_xdD3YxUbagL4dJp7Hwr4koZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59979 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752923AbdBHPL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 10:11:57 -0500
Content-Disposition: inline
In-Reply-To: <CAOMZO5BzLh4az9t=fJkG80GW3_xdD3YxUbagL4dJp7Hwr4koZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, after reverting this commit I no longer get the kernel crash.

And i guess you don't have a specific PHY driver for you PHYs. You are
using the generic PHY driver?

Could you try modifying phy_attach_direct() such that the
try_module_get() is after:

       /* Assume that if there is no driver, that it doesn't
         * exist, and we should use the genphy driver.
         */
        if (!d->driver) {
	<snip>
        } 

Thanks
	Andrew
