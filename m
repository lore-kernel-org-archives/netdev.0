From: Stefan Metzmacher <metze@samba.org>
Subject: cdc_ncm: Ericsson F5521gw appears as usbX, while Ericsson F3507g as wwanX
Date: Wed,  1 Jun 2011 12:08:32 +0200
Message-ID: <1306922913-17803-1-git-send-email-metze@samba.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Oliver Neukum <oliver@neukum.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.181]:26171 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758732Ab1FAKIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 06:08:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

commit e1e499eef2200c2a7120c9ebf297d48b195cf887
"usbnet: Use wwan%d interface name for mobile broadband devices"
introducted the FLAG_WWAN flag and caused the Ericsson F3507g
modem to appear as wwanX device instead of usbX.

commit c261344d3ce3edac781f9d3c7eabe2e96d8e8fe8
"usbnet: use eth%d name for known ethernet devices"
introduced the FLAG_POINTTOPOINT and added it to
the cdc_ncm modules without the FLAG_ETHER.

I'm wondering if the FLAG_POINTTOPOINT (without FLAG_ETHER)
should be changed to FLAG_WWAN instead.

I've changed that for the cdc_ncm driver in order to make Ericsson F5521gw
appear as wwanX, but I'm not sure if it's correct for all devices which
are supported by the cdc_ncm driver.

Maybe this should apply to all drivers in drivers/net/usb?

The following patch is just an example of what I'm currently using,
a possible upstream patch may need to look differently.

Comments please.

metze

