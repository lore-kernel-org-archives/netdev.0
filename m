From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] net: fsl_pq_mdio: fix oops when using uninitialized mutex
Date: Thu, 24 Nov 2011 01:50:58 -0600
Message-ID: <2465EDAB-01F8-4D5B-9950-E5F180E8A435@kernel.crashing.org>
References: <59b050a97a9b5382918b66f2850a80c86e52f409.1320736936.git.baruch@tkos.co.il> <CAKWjMd5WCx8pSJiL5U_WkD6XA5dSZLgLZkvMA6sjAKNuAz7PKg@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Baruch Siach <baruch@tkos.co.il>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33854 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810Ab1KXHv0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 02:51:26 -0500
In-Reply-To: <CAKWjMd5WCx8pSJiL5U_WkD6XA5dSZLgLZkvMA6sjAKNuAz7PKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 9, 2011, at 2:10 PM, Andy Fleming wrote:

>> Fix this by moving the of_mdiobus_register() call earlier.
>> 
>> Cc: Andy Fleming <afleming@freescale.com>
>> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
>> ---
>>  drivers/net/ethernet/freescale/fsl_pq_mdio.c |   14 +++++++-------
>>  1 files changed, 7 insertions(+), 7 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
>> index 52f4e8a..e17fd2f 100644
>> --- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
>> +++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
>> @@ -385,6 +385,13 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
>>                        tbiaddr = *prop;
>>        }
>> 
>> +       err = of_mdiobus_register(new_bus, np);
>> +       if (err) {
>> +               printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
>> +                               new_bus->name);
>> +               goto err_free_irqs;
>> +       }
>> +
> 
> 
> This fix totally breaks the point of setting tbipa beforehand.
> mdiobus_register will cause the bus to be scanned, and if any of the
> PHYs are at the default address for tbipa, they won't be found. I have
> a different fix which I will (re)submit today.

What happened here, did you send a patch?

- k