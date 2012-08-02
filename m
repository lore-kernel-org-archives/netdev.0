From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 1/2] net: davinci_mdio: enable and disable clock
Date: Thu, 2 Aug 2012 20:53:08 +0100
Message-ID: <20120802195308.GZ6802@n2100.arm.linux.org.uk>
References: <1343936616-29318-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com, paul@pwsan.com,
	devicetree-discuss@lists.ozlabs.org, koen@dominion.thruhere.net,
	linux-arm-kernel@lists.infradead.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:53560 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab2HBTxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 15:53:20 -0400
Content-Disposition: inline
In-Reply-To: <1343936616-29318-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 02, 2012 at 09:43:35PM +0200, Daniel Mack wrote:
> Make the driver control the device clocks. Appearantly, the Davinci
> platform probes this driver with the clock all powered up, but on OMAP,
> this isn't the case.

Hmm, this looks like it could do with improvement, especially as we're
moving everything over to a common clk API.

1. This driver could do with clk_prepare()/clk_unprepare() calls.
2. This driver should not be making the assumption that NULL means
   it can avoid clk_* calls.  It should instead be using
	if (!IS_ERR(clk))

Thanks.
