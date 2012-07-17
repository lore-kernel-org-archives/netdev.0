From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Tue, 17 Jul 2012 14:36:11 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F8D@saturn3.aculab.com>
References: <50044F1D.6000703@hp.com><20120716.222903.367603216293954363.davem@davemloft.net><AE90C24D6B3A694183C094C60CF0A2F6026B6F8B@saturn3.aculab.com> <20120717.055005.1912765690890797652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <rick.jones2@hp.com>, <cascardo@linux.vnet.ibm.com>,
	<netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<ogerlitz@mellanox.com>, <amirv@mellanox.com>,
	<brking@linux.vnet.ibm.com>, <leitao@linux.vnet.ibm.com>,
	<klebers@linux.vnet.ibm.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38900 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751060Ab2GQNgy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:36:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18093-02 for <netdev@vger.kernel.org>;
 Tue, 17 Jul 2012 14:36:52 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20120717.055005.1912765690890797652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Would there be any mileage in permanently allocating IOMMU
> > virtual address to the ring entries, then 'just' assigning
> > the correct physical address during rx/tx setup?
> 
> There is a not a one to one mapping between these two entities,
> in particular on the transmit side.
> 
> A transmit packet can have multiple segments, some of which are
> larger than one IOMMU page.

A SMOP :-) TX is probably easier than RX.
Each tx segment will already go into a separate ring entry,
page boundaries could do the same.
The driver will already have to cope with 'too many segments'
(I remember being passed a full sized frame made of a list
of 1-byte message blocks...)

Or allocate enough sequential IOMMU pages for the longest
tx segment for every ring entry - after all that is already
the 'worst case' allocation!

	David
