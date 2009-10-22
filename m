From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
 NOBALANCING and set affinity
Date: Wed, 21 Oct 2009 21:50:31 -0700 (PDT)
Message-ID: <20091021.215031.57955781.davem@davemloft.net>
References: <20091021022626.32449.73883.stgit@localhost.localdomain>
	<20091021022713.32449.54868.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60041
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751994AbZJVEuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 00:50:08 -0400
In-Reply-To: <20091021022713.32449.54868.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 20 Oct 2009 19:27:14 -0700

> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> This patch will set each MSI-X vector to IRQF_NOBALANCING to
> prevent autobalance of the interrupts, then applies a CPU
> affinity.  This will only be done when Flow Director is enabled,
> which needs interrupts to be processed on the same CPUs where the
> applications are running.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Just explain to me why irqbalanced in userspace cannot take care
of this issue.

Second, even if we cannot use irqbalanced for some reason, the last
thing I want to see is drivers directly fiddling with interrupt
states and attributes.  Every driver is going to do it every so
slightly differently, and often will get it wrong.

There is also no global policy or policy control available when
drivers do this stuff directly.  And that's how we end up with
situations where every driver behaves differently which results in a
terrible user experience.
