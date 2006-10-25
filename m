From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] !CONFIG_NET_ETHERNET unsets CONFIG_PHYLIB, but
 CONFIG_USB_USBNET also needs CONFIG_PHYLIB
Date: Wed, 25 Oct 2006 15:27:09 -0700
Message-ID: <20061025222709.A13681C5E0B@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org>
 <20061025201341.GH21200@miggy.org>
 <20061025151737.1bf4898c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zippel@linux-m68k.org, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.sbc.mail.mud.yahoo.com ([68.142.198.209]:26448 "HELO
	smtp110.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S965239AbWJYW1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 18:27:16 -0400
To: toralf.foerster@gmx.de, randy.dunlap@oracle.com,
	netdev@vger.kernel.org, linux-usb-devel@lists.sourceforge.net,
	link@miggy.org, greg@kroah.com, akpm@osdl.org
In-Reply-To: <20061025151737.1bf4898c.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -94,6 +95,7 @@ config USB_RTL8150
>  
>  config USB_USBNET
>  	tristate "Multi-purpose USB Networking Framework"
> +	select MII
>  	---help---
>  	  This driver supports several kinds of network links over USB,
>  	  with "minidrivers" built around a common network driver core

The other parts are right, this isn't.

Instead, "usbnet.c" should #ifdef the relevant ethtool hooks
according to CONFIG_MII ... since it's completely legit to
use usbnet with peripherals that don't need MII.

