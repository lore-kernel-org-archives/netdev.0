From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 39 of 39] IB/ipath - use streaming copy in RDMA
 interrupt handler to reduce packet loss
Date: Thu, 29 Jun 2006 16:46:23 -0700 (PDT)
Message-ID: <20060629.164623.59469884.davem@davemloft.net>
References: <1151618377.10886.23.camel@chalcedony.pathscale.com>
	<20060629.150319.104035601.davem@davemloft.net>
	<1151624063.10886.34.camel@chalcedony.pathscale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, rdreier@cisco.com, mst@mellanox.co.il,
	openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26762
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933108AbWF2Xq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 19:46:26 -0400
To: bos@pathscale.com
In-Reply-To: <1151624063.10886.34.camel@chalcedony.pathscale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bryan O'Sullivan <bos@pathscale.com>
Date: Thu, 29 Jun 2006 16:34:23 -0700

> I'm not quite following you, though I assume you're referring to Niagara
> or Rock :-)  Are you saying a memcpy_nc would do worse than plain
> memcpy, or worse than some other memcpy-like routine?

It would do worse than memcpy.

If you bypass the L2 cache, it's pointless because the next
agent (PCI controller, CPU thread, etc.) is going to need the
data in the L2 cache.

It's better in that kind of setup to eat the L2 cache miss overhead in
memcpy since memcpy can usually prefetch and store buffer in order to
absorb some of the L2 miss costs.
