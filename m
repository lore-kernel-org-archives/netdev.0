From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4 v2] ks8851: read/write MAC address on companion
 eeprom through debugfs
Date: Thu, 06 May 2010 00:25:08 -0700 (PDT)
Message-ID: <20100506.002508.241926083.davem@davemloft.net>
References: <1273085155-1260-1-git-send-email-s-jan@ti.com>
	<1273085155-1260-5-git-send-email-s-jan@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	x0066660@ti.com, ben-linux@fluff.org, Tristram.Ha@micrel.com
To: s-jan@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57044
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751296Ab0EFHZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:25:02 -0400
In-Reply-To: <1273085155-1260-5-git-send-email-s-jan@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastien Jan <s-jan@ti.com>
Date: Wed,  5 May 2010 20:45:55 +0200

> A more elegant alternative to ethtool for updating the ks8851
> MAC address stored on its companion eeprom.
> Using this debugfs interface does not require any knowledge on the
> ks8851 companion eeprom organization to update the MAC address.
> 
> Example to write 01:23:45:67:89:AB MAC address to the companion
> eeprom (assuming debugfs is mounted in /sys/kernel/debug):
> $ echo "01:23:45:67:89:AB" > /sys/kernel/debug/ks8851/mac_eeprom
> 
> Signed-off-by: Sebastien Jan <s-jan@ti.com>

Elegant?  This commit message is the biggest lie ever told.

What makes your ethernet driver so god-damn special that it deserves
to have a private, completely unique, and obscure interface for
setting the permanent ethernet address of a network device?

Tell me how damn elegant it is that users have to learn about this
special, unique, and common with no other driver, interface for
performing this task?

Tell me how damn elegant it is when another driver wants to provide
users with a way to do this too, and they (like you) come up with
their own unique and different interface for doing this.

No, this is the most inelegant patch ever conceived because it totally
ignores the way in which we handle issues like this.

There is no way in the world I'm applying this garbage patch, sorry.

We have an ETHTOOL_GPERMADDR, add a new ETHTOOL_SPERMADDR operation
and then any driver (not just your's) can portably provide this
facility and users will have one, and only one, way of performing this
task.
