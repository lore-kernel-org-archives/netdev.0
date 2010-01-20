From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 15:41:26 -0800 (PST)
Message-ID: <20100120.154126.152942350.davem@davemloft.net>
References: <20100120.145218.259766536.davem@davemloft.net>
	<20100120232102.GD3072@del.dom.local>
	<20100120.153451.62650459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50026
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751626Ab0ATXlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:41:17 -0500
In-Reply-To: <20100120.153451.62650459.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 20 Jan 2010 15:34:51 -0800 (PST)

> Whereas 1 patch in the 1 place in the DMA API implementation would fix
> everything for everybody.

For the record I just checked DMAR and Intel-IOMMU and they
don't even implement the SYNC ops, they are NULL and thus
can't be effected by the changes being discussed here.

The generic DMA SYNC operations check for a NULL function
pointer in the DMA operations, and do nothing if it is NULL.

Thus, so far it is proven that only the DMA debugging code 
actually has this SYNC length requirement.
