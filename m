From: David Miller <davem@davemloft.net>
Subject: Re: [1/1] ARC vmac ethernet driver.
Date: Mon, 15 Mar 2010 15:35:33 -0700 (PDT)
Message-ID: <20100315.153533.78183177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andreas.fenkart@streamunlimited.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35042
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932149Ab0COWfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:35:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This needs some changes.

First, you'll need to add some proper dependencies to the Kconfig for
this driver before we can apply it.

At a minimum you have to depend upon HAS_DMA otherwise the
dma_*() interface calls won't link on platforms such as s390.

Also:

+static char *mac_addr;
+module_param(mac_addr, charp, 0644);
+MODULE_PARM_DESC(mac_addr, "MAC address as colon separated hexadecimals");

Please remove this, we have interfaces for setting the ethernet
address.  If the device address can't be probed, use
a random ethernet address as a default (by using linux/etherdevice.h's
random_ether_addr())

If the user wants to override they can do so with the 'ifconfig'
command.

This is how we consistently handle this situation in every ethernet
driver, so please don't try to make arguments as to why your driver
should handle this differently.

Thanks.
