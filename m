From: Liviu Dudau <liviu@dudau.co.uk>
Subject: Re: [PATCH net-next] net: phy: use of_mdio_parse_addr
Date: Wed, 7 Jun 2017 17:18:55 +0100
Message-ID: <20170607161854.GC4389@bart.dudau.co.uk>
References: <1496259810-3602-1-git-send-email-jon.mason@broadcom.com>
 <20170602.142251.851089443438560012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jon.mason@broadcom.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dliviu.plus.com ([80.229.23.120]:45842 "EHLO smtp.dudau.co.uk"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750831AbdFGQZH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 12:25:07 -0400
Content-Disposition: inline
In-Reply-To: <20170602.142251.851089443438560012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 02, 2017 at 02:22:51PM -0400, David Miller wrote:
> From: Jon Mason <jon.mason@broadcom.com>
> Date: Wed, 31 May 2017 15:43:30 -0400
> 
> > use of_mdio_parse_addr() in place of an OF read of reg and a bounds
> > check (which is litterally the exact same thing that
> > of_mdio_parse_addr() does)
> > 
> > Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> 
> Applied, thanks Jon.

This makes linux-next fail the modules_install target as depmod detects 2 circular
dependencies. Reverting this patch fixes the issue.

depmod: ERROR: Cycle detected: libphy -> of_mdio -> fixed_phy -> libphy
depmod: ERROR: Cycle detected: libphy -> of_mdio -> libphy
depmod: ERROR: Found 3 modules in dependency cycles!
make[1]: *** [/home/dliviu/devel/kernel/Makefile:1245: _modinst_post] Error 1

This is on an ARCH=arm build, build I doubt it makes a difference. Let me know if
you need some .config values in order to reproduce.

Best regards,
Liviu
