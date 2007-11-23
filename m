From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] [RFC] New driver "sfc" for Solarstorm SFC4000 controller
Date: Fri, 23 Nov 2007 17:08:15 +0000
Message-ID: <20071123170815.GH31093@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pythagoras.zen.co.uk ([212.23.3.140]:32803 "EHLO
	pythagoras.zen.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbXKWRIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 12:08:21 -0500
Received: from [82.69.137.158] (helo=opal.uk.level5networks.com)
	by pythagoras.zen.co.uk with esmtp (Exim 4.50)
	id 1Ivc0p-0006bA-3U
	for netdev@vger.kernel.org; Fri, 23 Nov 2007 17:08:19 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a net driver (and MTD driver, sfc_mtd) for our SFC4000 10G
Ethernet controller, branded "Solarstorm", with various PHYs.  It is
intended to support our NIC reference designs SFE4001 (10GBASE-T),
SFE4002 (XFP), SFE4003 (10GBASE-CX4), OEM designs based on them, and
some development boards.  We have been maintaining drivers out-of-tree
for some time but are now preparing them to work in-tree.

There are some issues that might need to be addressed:

1. When we enable NAPI polling, we need to set __LINK_STATE_START in
   the net device used for NAPI.  This bit is commented as private in
   netdevice.h, but e1000 also does this.  Is this incorrect?

2. We added a lot of definitions and code for 10G MDIO.  This is mostly
   generic and could be moved into core code.

We welcome review comments and are ready to address them.

The patch (against net-2.6.25) is at:
    https://support.solarflare.com/netdev/net-2.6.25-sfc-2.2.0019.patch

The new files may also be downloaded as a tarball:
    https://support.solarflare.com/netdev/net-2.6.25-sfc-2.2.0019.tar.gz

And for verification there is:
    https://support.solarflare.com/netdev/MD5SUMS

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
