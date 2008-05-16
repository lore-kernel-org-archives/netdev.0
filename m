From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH -next] 3c515: fix using pnp_get_resource when CONFIG_ISAPNP=n
Date: Fri, 16 May 2008 11:21:35 -0700
Message-ID: <482DD0AF.7070003@oracle.com>
References: <20080516103524.0b00ffb6.randy.dunlap@oracle.com> <200805161215.06046.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jgarzik <jgarzik@pobox.com>,
	linux-next@vger.kernel.org, akpm <akpm@linux-foundation.org>
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:33936 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759732AbYEPSXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 14:23:24 -0400
In-Reply-To: <200805161215.06046.bjorn.helgaas@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bjorn Helgaas wrote:
> On Friday 16 May 2008 11:35:24 am Randy Dunlap wrote:
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> 3c515.c uses pnp_irq(), which calls pnp_get_resource(),
>> which is not defined when CONFIG_PNP=n, so in that case,
>> get the IRQ from a hardware register.
>>
>> 3c515.c:(.text+0x3adc0): undefined reference to `pnp_get_resource'
>>
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Hmm, wonder why my allyesconfig didn't catch this one.

Because parts of it are =n.  :)

> I prefer CONFIG_PNP to __ISAPNP__ in general, but I see
> you're just following the other tests in the same file.

Yes.  And it would need to be CONFIG_ISAPNP, not CONFIG_PNP.

> 
> Thanks!
> 
> Acked-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
> 
>> ---
>>  drivers/net/3c515.c |    4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> --- next-20080516.orig/drivers/net/3c515.c
>> +++ next-20080516/drivers/net/3c515.c
>> @@ -572,12 +572,16 @@ static int corkscrew_setup(struct net_de
>>  	int irq;
>>  	DECLARE_MAC_BUF(mac);
>>  
>> +#ifdef __ISAPNP__
>>  	if (idev) {
>>  		irq = pnp_irq(idev, 0);
>>  		vp->dev = &idev->dev;
>>  	} else {
>>  		irq = inw(ioaddr + 0x2002) & 15;
>>  	}
>> +#else
>> +	irq = inw(ioaddr + 0x2002) & 15;
>> +#endif
>>  
>>  	dev->base_addr = ioaddr;
>>  	dev->irq = irq;
>>
> 
> 


-- 
~Randy
