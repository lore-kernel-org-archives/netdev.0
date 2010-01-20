From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 14:52:18 -0800 (PST)
Message-ID: <20100120.145218.259766536.davem@davemloft.net>
References: <20100120204459.820265084@vyatta.com>
	<20100120204558.901334592@vyatta.com>
	<20100120213259.GB3072@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50251
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754033Ab0ATWwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 17:52:07 -0500
In-Reply-To: <20100120213259.GB3072@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 20 Jan 2010 22:32:59 +0100

> On Wed, Jan 20, 2010 at 12:45:01PM -0800, Stephen Hemminger wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> 
>> Using pci_unmap_len(), with the same length as pci_map_single(), with
>> pci_dma_sync_single_for_cpu()/_device() fixes this warning (2.6.32.4):
>> 
>> > Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902 
>> > check_sync+0xc1/0x43f()
>> > Jan 19 10:43:50 mail kernel: Hardware name: System Product Name
>> > Jan 19 10:43:50 mail kernel: sky2 0000:04:00.0: DMA-API: device driver 
>> > tries to sync DMA memory it has not allocated [device 
>> > address=0x0000000320a0b022] [size=60 bytes]  
>> 
>> Reported-by: Michael Breuer <mbreuer@majjas.com>
>> Tested-by: Michael Breuer <mbreuer@majjas.com>
>> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Thanks for acking and completing this, Stephen!

It's not a bug, lib/dma-debug.c and the DMA API documentation
are both buggy.

I'm not applying any of this, the fix belongs in the infrastructure
debugging and documentation not in the drivers, they are doing the
correct and only reasonable thing.
