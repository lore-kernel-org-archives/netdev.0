From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: Re: [PATCH] net: ibm: emac: Fix some error handling path in
 'emac_probe()'
Date: Sun, 20 Aug 2017 06:41:38 +0200
Message-ID: <c53d0760-1ad2-1275-d33a-2f8b0eb55fb7@wanadoo.fr>
References: <20170818230757.10934-1-christophe.jaillet@wanadoo.fr>
 <2515086.XcP7alDqkk@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, jarod@redhat.com, ivan@de.ibm.com,
        ebiggers@google.com, tklauser@distanz.ch, tremyfr@gmail.com,
        robh@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <2515086.XcP7alDqkk@debian64>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 19/08/2017 à 15:22, Christian Lamparter a écrit :
> On Saturday, August 19, 2017 1:07:57 AM CEST Christophe JAILLET wrote:
>> If 'irq_of_parse_and_map()' or 'of_address_to_resource()' fail, 'err' is
>> known to be 0 at this point.
>> So return -ENODEV instead in the first case and propagate the error
>> returned by 'of_address_to_resource()' in the 2nd case.
>>
>> While at it, turn a 'err != 0' test into an equivalent 'err' to be more
>> consistent.
>>
>> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
>> ---
>>   drivers/net/ethernet/ibm/emac/core.c | 6 ++++--
>>   1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
>> index 95135d20458f..1af56a97fb47 100644
>> --- a/drivers/net/ethernet/ibm/emac/core.c
>> +++ b/drivers/net/ethernet/ibm/emac/core.c
>> [...]
>>   	/* Map EMAC regs */
>> -	if (of_address_to_resource(np, 0, &dev->rsrc_regs)) {
>> +	err = of_address_to_resource(np, 0, &dev->rsrc_regs);
>> +	if (err) {
>>   		printk(KERN_ERR "%pOF: Can't get registers address\n", np);
>>   		goto err_irq_unmap;
>>   	}
>>   // TODO : request_mem_region
>>   dev->emacp = ioremap(dev->rsrc_regs.start,
>>                        resource_size(&dev->rsrc_regs));
>>   ...
> If you want to go for 101%: you could get rid of this block
> altogether by doing:
> 	dev->emacp = of_iomap(np, 0);
>
> Note1:
> This will also make the rsrc_regs variable in the emac_instance
> struct redundant. So simply remove it from the core.h.
>
> Note2: if you want to go for 110%, you could replace this with
> platform_get_resource() and devm_ioremap_resource() (if you
> are interested, take a look at devm_ioremap_resource's kdoc
> it has an example).
>
> Thanks,
> Christian
>
Hi,

Thanks for the review and comments.

I've sent a v2 to go for 101% which axes some lines of code.

I won't propose anything for your other proposal. Sounds great but 
involves more changes in the error handling path and in the remove function.
I don't have the hardware, so I won't be able to test this bigger change.

Christophe

