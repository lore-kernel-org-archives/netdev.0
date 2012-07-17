From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Tue, 17 Jul 2012 13:42:04 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F8B@saturn3.aculab.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com><50044F1D.6000703@hp.com> <20120716.222903.367603216293954363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <cascardo@linux.vnet.ibm.com>, <netdev@vger.kernel.org>,
	<yevgenyp@mellanox.co.il>, <ogerlitz@mellanox.com>,
	<amirv@mellanox.com>, <brking@linux.vnet.ibm.com>,
	<leitao@linux.vnet.ibm.com>, <klebers@linux.vnet.ibm.com>
To: "David Miller" <davem@davemloft.net>, <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37637 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753177Ab2GQMms convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 08:42:48 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03633-07 for <netdev@vger.kernel.org>;
 Tue, 17 Jul 2012 13:42:45 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20120716.222903.367603216293954363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > That seems rather extraordinarily low - Power7 is supposed to be a
> > rather high performance CPU.  The last time I noticed O(3Gbit/s) on
> > 10G for bulk transfer was before the advent of LRO/GRO - that was in
> > the x86 space though.  Is mapping really that expensive with Power7?
> 
> Unfortunately, IOMMU mappings are incredibly expensive.  I see effects
> like this on Sparc too.

Would there be any mileage in permanently allocating IOMMU
virtual address to the ring entries, then 'just' assigning
the correct physical address during rx/tx setup?

A long time ago it used to be much faster on sparc systems
to receive into a permanently mapped buffer area and then
do a maximally aligned copy into the actual rx buffer.

	David
