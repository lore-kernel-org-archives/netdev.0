From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Tue, 17 Jul 2012 05:50:05 -0700 (PDT)
Message-ID: <20120717.055005.1912765690890797652.davem@davemloft.net>
References: <50044F1D.6000703@hp.com>
	<20120716.222903.367603216293954363.davem@davemloft.net>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6F8B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, cascardo@linux.vnet.ibm.com,
	netdev@vger.kernel.org, yevgenyp@mellanox.co.il,
	ogerlitz@mellanox.com, amirv@mellanox.com,
	brking@linux.vnet.ibm.com, leitao@linux.vnet.ibm.com,
	klebers@linux.vnet.ibm.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717Ab2GQNDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:03:54 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6F8B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Tue, 17 Jul 2012 13:42:04 +0100

> Would there be any mileage in permanently allocating IOMMU
> virtual address to the ring entries, then 'just' assigning
> the correct physical address during rx/tx setup?

There is a not a one to one mapping between these two entities,
in particular on the transmit side.

A transmit packet can have multiple segments, some of which are
larger than one IOMMU page.
