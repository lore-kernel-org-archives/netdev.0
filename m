From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: [PATCH 1/1] qlcnic: add wmb() call in transmit data path.
Date: Thu, 30 Jun 2016 18:48:25 +0000
Message-ID: <CY1PR11MB08870104F21B3345D1C6301C82240@CY1PR11MB0887.namprd11.prod.outlook.com>
References: <1467237094-23088-1-git-send-email-sony.chacko@qlogic.com>
 <1467237094-23088-2-git-send-email-sony.chacko@qlogic.com>
 <57753B8F.9020302@marvell.com> <57753DBB.9010608@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Lino Sanfilippo <lsanfil@marvell.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0115.outbound.protection.outlook.com ([104.47.33.115]:43704
	"EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751673AbcGABMv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 21:12:51 -0400
In-Reply-To: <57753DBB.9010608@marvell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: Re: [PATCH 1/1] qlcnic: add wmb() call in transmit data path.

>
>> +    /* Ensure writes are complete before HW fetches Tx descriptors */
>> +    wmb();
>>       qlcnic_update_cmd_producer(tx_ring);
>>
>>       return NETDEV_TX_OK;
>>
>
> Would not an mmiowb be more appropriate in this case?
>
> Regards,
> Lino

Sorry, this was nonsense.This should be "dma_wmb" not "mmiowb".

Lino,

The patch is based on this kernel documentation. 

https://www.kernel.org/doc/Documentation/memory-barriers.txt
	
	/* force memory to sync before notifying device via MMIO */
		wmb();

		/* notify device of new descriptors */
		writel(DESC_NOTIFY, doorbell);
	}
The wmb() is needed to guarantee that the cache coherent memory writes have 
completed before attempting a write to the cache incoherent MMIO region.

Thanks,
Sony
