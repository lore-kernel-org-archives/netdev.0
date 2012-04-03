From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] marvell sky2 driver: fix irq number assignment bug
Date: Tue, 03 Apr 2012 17:41:39 -0400 (EDT)
Message-ID: <20120403.174139.1088270699067881012.davem@davemloft.net>
References: <201204031526.q33FQvFO031746@farm-0027.internal.tilera.com>
	<1333468024.2577.21.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333468024.2577.21.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 3 Apr 2012 16:47:04 +0100

> On Tue, 2012-04-03 at 11:10 -0400, Chris Metcalf wrote:
>> Fix a minor bug that will display wrong IRQ number in ifconfig output.
>> 
>> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
>> ---
>>  drivers/net/ethernet/marvell/sky2.c |    7 +++++++
>>  1 files changed, 7 insertions(+), 0 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
>> index 423a1a2..879b0a4 100644
>> --- a/drivers/net/ethernet/marvell/sky2.c
>> +++ b/drivers/net/ethernet/marvell/sky2.c
>> @@ -4978,6 +4978,13 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
>>  			goto err_out_free_netdev;
>>   	}
>>  
>> +	/*
>> +	 * Need to set the IRQ # for the net_device here again after
>> +	 * setting it in sky2_init_netdev() initially, because MSI
>> +	 * will assign a new IRQ # to this PCI device.
>> +	 */
>> +	dev->irq = hw->pdev->irq;
>> +
>>  	err = register_netdev(dev);
>>  	if (err) {
>>  		dev_err(&pdev->dev, "cannot register net device\n");
> 
> I think the consensus now is that net_device::irq should be left at 0
> for devices that don't support manual configuration (ISA and the like).

Agreed.
