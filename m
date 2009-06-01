From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: add phy_power_down parameter, leave phy
 powered up by default
Date: Mon, 01 Jun 2009 02:48:34 -0700 (PDT)
Message-ID: <20090601.024834.119882380.davem@davemloft.net>
References: <1243724386.13996.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com
To: eswierk@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51515
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753902AbZFAJse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 05:48:34 -0400
In-Reply-To: <1243724386.13996.17.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ed Swierk <eswierk@aristanetworks.com>
Date: Sat, 30 May 2009 15:59:46 -0700

> Add a phy_power_down parameter to forcedeth: set to 1 to power down the
> phy and disable the link when an interface goes down; set to 0 to always
> leave the phy powered up.
> 
> The phy power state persists across reboots; Windows, some BIOSes, and
> older versions of Linux don't bother to power up the phy again, forcing
> users to remove all power to get the interface working (see
> http://bugzilla.kernel.org/show_bug.cgi?id=13072).  Leaving the phy
> powered on is the safest default behavior.  Users accustomed to seeing
> the link state reflect the interface state and/or wanting to minimize
> power consumption can set phy_power_down=1 if compatibility with other
> OSes is not an issue.
> 
> Signed-off-by: Ed Swierk <eswierk@aristanetworks.com>

Yes, this is probably the thing to do, but...

+enum {
+	NV_PHY_POWER_DOWN_NEVER,
+	NV_PHY_POWER_DOWN_ON_INTF_DOWN
+};
+static int phy_power_down = NV_PHY_POWER_DOWN_NEVER;
...
+module_param(phy_power_down, int, 0);
+MODULE_PARM_DESC(phy_power_down, "Power down phy and disable link when interface is down (1), or always leave phy powered up (0).");

Using an enum is gratuitous, and if you want to guarentee the
enum values start at zero you have to explicitly assign the
first enum value at zero.

But again it's gratuitous, and it's better to just explicitly
use '0' and '1 in this kind of situation.

Please fix this up and resubmit, thanks.
