From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] sfc: Fix SFE4002 initialisation
Date: Fri, 12 Feb 2010 12:32:36 -0800 (PST)
Message-ID: <20100212.123236.90513347.davem@davemloft.net>
References: <1265730777.2126.110.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35845
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756252Ab0BLUcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:32:21 -0500
In-Reply-To: <1265730777.2126.110.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 09 Feb 2010 15:52:57 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> Commit 357d46a17e54c9a87e0e6ef3930ff4ab2d232b81 "sfc: QT202x: Remove
> unreliable MMD check at initialisation" broke initialisation of the
> SFE4002.  efx_mdio_reset_mmd() returns a positive value rather than 0
> on success.  The above commit causes this value to be propagated up
> by qt202x_reset_phy(), which is treated as a failure by its callers.
> Change qt202x_reset_phy() to return 0 if successful.
> 
> The PCI layer treats >0 as "fail, but please call remove() anyway",
> which means that unloading the driver would cause a crash.  Add a
> WARN_ON() on the failure path of efx_pci_probe() to provide early
> warning if there are any other cases where we do this.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-2.6, thanks.
