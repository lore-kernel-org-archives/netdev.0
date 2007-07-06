From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Fri, 06 Jul 2007 12:20:19 -0700 (PDT)
Message-ID: <20070706.122019.55506705.davem@davemloft.net>
References: <20070705.171535.105173068.davem@davemloft.net>
	<08FE5CC30C9A3F41BF819A502CF7BF6E0198249D@fmsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55159
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757983AbXGFTT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 15:19:57 -0400
In-Reply-To: <08FE5CC30C9A3F41BF819A502CF7BF6E0198249D@fmsmsx411.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Date: Fri, 6 Jul 2007 10:14:56 -0700

> In my opinion, IOMMU table locking is the major issue with this type of
> architecture.  Since both Intel and AMD are touting IOMMUs for virtual-
> ization support, this is an issue that's going to need a lot of
> scrutiny.

For the allocation of IOMMU entries themselves you can play tricks
using atomic operations on 64-bit words of the allocator bitmap
to avoid locking that.

You can use per-cpu salts to determine where to start the search
and avoid hitting the same cachelines as other cpus working on
the same table.

But you'll need to lock in order to flush the IOMMU tlb I'm afraid.
The way to mitigate that is to only flush the IOMMU tlb once per
allocator generation.
