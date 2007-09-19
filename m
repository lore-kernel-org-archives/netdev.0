From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 18:05:25 -0400
Message-ID: <46F19D25.2010403@garzik.org>
References: <20070918.151528.84360712.davem@davemloft.net> <20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ariel.Hendel@sun.com, greg.onufer@sun.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51134 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbXISWF2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 18:05:28 -0400
In-Reply-To: <20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> O
>> +#define DRV_MODULE_NAME		"niu"
>> +#define PFX DRV_MODULE_NAME	": "
>> +#define DRV_MODULE_VERSION	"0.06"
>> +#define DRV_MODULE_RELDATE	"September 18, 2007"
>> +
>> +static char version[] __devinitdata =
>> +	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
>> +
>> +MODULE_AUTHOR("David S. Miller (davem@davemloft.net)");
>> +MODULE_DESCRIPTION("NIU ethernet driver");
>> +MODULE_LICENSE("GPL");
>> +MODULE_VERSION(DRV_MODULE_VERSION);
>> +
>> +#ifndef DMA_44BIT_MASK
>> +#define DMA_44BIT_MASK	0x00000fffffffffffULL
>> +#endif
>> +
>> +#ifndef PCI_DEVICE_ID_SUN_NEPTUNE
>> +#define PCI_DEVICE_ID_SUN_NEPTUNE	0xabcd
>> +#endif
> 
> Why bother defining the ID

Yes, its pointless to use anything but the hex number for PCI IDs that 
are only used in a single place.


>> +static struct pci_device_id niu_pci_tbl[] = {
>> +	{PCI_DEVICE(PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_NEPTUNE),
>> +	 .driver_data = 0xff},
>> +	{}
>> +};
>> +
>> +MODULE_DEVICE_TABLE(pci, niu_pci_tbl);
>> +
>> +#define NIU_TX_TIMEOUT			(5 * HZ)
>> +
>> +#define nr64(reg)		readq(np->regs + (reg))
>> +#define nw64(val, reg)		writeq((val), np->regs + (reg))
> 
> Macro's that make assumptions about context (ie variable name np)
> are evil and bad style.

No, that's a common and encouraged convenience that makes the code a lot 
easier to read.

That said, the 2-arg macro arg order is wrong.  It should be (reg,val) 
like tg3 and other drivers.

	Jeff



