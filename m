From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Tue, 17 Jul 2012 15:50:59 +0200
Message-ID: <1342533059.2626.661.camel@edumazet-glaptop>
References: <50044F1D.6000703@hp.com>
	 <20120716.222903.367603216293954363.davem@davemloft.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B6F8B@saturn3.aculab.com>
	 <20120717.055005.1912765690890797652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, rick.jones2@hp.com,
	cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.co.il, ogerlitz@mellanox.com, amirv@mellanox.com,
	brking@linux.vnet.ibm.com, leitao@linux.vnet.ibm.com,
	klebers@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43738 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359Ab2GQNvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:51:07 -0400
Received: by eekc13 with SMTP id c13so165896eek.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 06:51:05 -0700 (PDT)
In-Reply-To: <20120717.055005.1912765690890797652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 05:50 -0700, David Miller wrote:
> From: "David Laight" <David.Laight@ACULAB.COM>
> Date: Tue, 17 Jul 2012 13:42:04 +0100
> 
> > Would there be any mileage in permanently allocating IOMMU
> > virtual address to the ring entries, then 'just' assigning
> > the correct physical address during rx/tx setup?
> 
> There is a not a one to one mapping between these two entities,
> in particular on the transmit side.
> 
> A transmit packet can have multiple segments, some of which are
> larger than one IOMMU page.

And on rx side, permanently allocating IOMMU would need to copy all
incoming frames to newly allocated memory.

Annot this IOMMU performance problem can be solved on its side,
instead of having to shuffle things in all drivers ?
