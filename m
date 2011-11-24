From: Fleming Andy-AFLEMING <afleming@freescale.com>
Subject: Re: [PATCH] net: fsl_pq_mdio: fix oops when using uninitialized
 mutex
Date: Thu, 24 Nov 2011 17:46:40 +0000
Message-ID: <64079AFE-7F15-4207-BEC2-E5F9CC7D7C93@freescale.com>
References: <59b050a97a9b5382918b66f2850a80c86e52f409.1320736936.git.baruch@tkos.co.il>
 <CAKWjMd5WCx8pSJiL5U_WkD6XA5dSZLgLZkvMA6sjAKNuAz7PKg@mail.gmail.com>,<2465EDAB-01F8-4D5B-9950-E5F180E8A435@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Andy Fleming <afleming@gmail.com>,
	Baruch Siach <baruch@tkos.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:14480
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820Ab1KXRrq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Nov 2011 12:47:46 -0500
In-Reply-To: <2465EDAB-01F8-4D5B-9950-E5F180E8A435@kernel.crashing.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, I sent a patch. Then he sent another patch which breaks things differently. I have not yet submitted my fix. My fix is to revert his patch, and then modify your updated device trees to automatically set the tbi to something.

On Nov 24, 2011, at 1:51, "Kumar Gala" <galak@kernel.crashing.org> wrote:

> 
> On Nov 9, 2011, at 2:10 PM, Andy Fleming wrote:
> 
>>> Fix this by moving the of_mdiobus_register() call earlier.
>>> 
>>> Cc: Andy Fleming <afleming@freescale.com>
>>> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
>>> ---
>>> drivers/net/ethernet/freescale/fsl_pq_mdio.c |   14 +++++++-------
>>> 1 files changed, 7 insertions(+), 7 deletions(-)
>>> 
>>> diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
>>> index 52f4e8a..e17fd2f 100644
>>> --- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
>>> +++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
>>> @@ -385,6 +385,13 @@ static int fsl_pq_mdio_probe(struct platform_device *ofdev)
>>>                       tbiaddr = *prop;
>>>       }
>>> 
>>> +       err = of_mdiobus_register(new_bus, np);
>>> +       if (err) {
>>> +               printk (KERN_ERR "%s: Cannot register as MDIO bus\n",
>>> +                               new_bus->name);
>>> +               goto err_free_irqs;
>>> +       }
>>> +
>> 
>> 
>> This fix totally breaks the point of setting tbipa beforehand.
>> mdiobus_register will cause the bus to be scanned, and if any of the
>> PHYs are at the default address for tbipa, they won't be found. I have
>> a different fix which I will (re)submit today.
> 
> What happened here, did you send a patch?
> 
> - k
