From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/33] sfc: Do not use pci_disable_device() to disable
 bus mastering
Date: Fri, 12 Dec 2008 21:31:08 -0800 (PST)
Message-ID: <20081212.213108.52725498.davem@davemloft.net>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	<20081212124622.GK32518@solarflare.com>
	<20081212124913.GC10372@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58413
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751619AbYLMFbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:31:07 -0500
In-Reply-To: <20081212124913.GC10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 12 Dec 2008 12:49:14 +0000

> pci_disable_device() disables many features, like MSI-X, which we
> never reenable in efx_reset().  Further, calls to pci_enable_device()
> and pci_disable_device() must be matched since the nesting count was
> introduced.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Since the PCI layer provides interfaces which do manage
this setting, there is no way you should be doing this
behind it's back.

You know why?

Because someone is going to change some of the internals
of this stuff in the PIC layer and it will break your
driver.

Please instead submit an interface to the PCI layer
maintainers that does what you want, then use it.

Patch not applied.
