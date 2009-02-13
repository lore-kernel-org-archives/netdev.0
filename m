From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/6] mv643xx_eth updates
Date: Fri, 13 Feb 2009 01:06:15 +0100
Message-ID: <20090213000615.GJ17914@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:42994 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbZBMAGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:06:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two things here:
- Exporting some functionality that mostly already existed in the
  driver (interrupt coalescing, etc) to userland via ethtool.
- Add Kconfig-configurable LRO support.

I have two more patches:
1. Set the default rx coal value to something other than zero,
   since 100us or 200us or 500us all provide very nice performance
   improvements (especially combined with LRO -- a 1.2GHz ARM with
   256K of cache can receive line rate gigabit and copy it all to
   userland with ~70% CPU usage when LRO and rx coalescing are
   enabled, whereas it does ~80MB/s with 100% CPU usage if those
   are both off).
2. Receive into pages (to speed up TCP splice receive).

But (1) still needs some benchmarking to see what the best default
value would be for a wider range of hardware, and (2) I'm not yet
happy about.
