From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
	NOBALANCING and set affinity
Date: Wed, 18 Nov 2009 19:46:10 +0000
Message-ID: <1258573570.2780.14.camel@achroite.uk.solarflarecom.com>
References: <20091021022713.32449.54868.stgit@localhost.localdomain>
	 <20091021.215031.57955781.davem@davemloft.net>
	 <F86E8680A7D9D74A99DC6345E35A69293E3D4171@orsmsx503.amr.corp.intel.com>
	 <20091118.101030.22004862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, jeffrey.t.kirsher@intel.com,
	gospo@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:20265 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758367AbZKRTqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 14:46:12 -0500
In-Reply-To: <20091118.101030.22004862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-18 at 10:10 -0800, David Miller wrote:
> From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
> Date: Thu, 12 Nov 2009 11:12:22 -0800
> 
> > Jesse Brandeburg and I talked with Arjan yesterday regarding these patches.
> 
> Thanks for the update.
> 
> > We also discussed the need for irqbalance to distinguish between Rx
> > and Tx queue vectors.  Right now, irqbalance can identify an
> > interrupt belong to an Ethernet device, but it stops there.  It
> > needs to also distinguish the directional vectors, and make sure to
> > balance the right queue vector with its paired queue (i.e. make sure
> > Tx queue 0's vector lines up with Rx queue 0's vector).
> 
> Why don't you just simply use the same MSI-X vector for both TX
> queue 0 and RX queue 0, can't your hardware do that?
> 
> That's what I plan on doing in the NIU driver soon.

When forwarding between 2 ports it can be beneficial to match the
affinity of each port's TX interrupts with the other port's RX
interrupts.  Obviously this is not the case when the system is acting as
an endpoint, and the situation is presumably more complex when
forwarding between >2 ports.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

