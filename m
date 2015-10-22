From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Wed, 21 Oct 2015 18:24:30 -0700 (PDT)
Message-ID: <20151021.182430.565026583970438038.davem@davemloft.net>
References: <20151021.083311.2193871332944250588.davem@davemloft.net>
	<4129407.LpDXnpSZOL@wuerfel>
	<5627C549.9080600@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5627C549.9080600@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 21 Oct 2015 10:03:05 -0700

> On 10/21/2015 08:57 AM, Arnd Bergmann wrote:
>> On Wednesday 21 October 2015 08:33:11 David Miller wrote:
>>> From: Guenter Roeck <linux@roeck-us.net>
>>> Date: Wed, 21 Oct 2015 07:56:18 -0700
>>>
>>>>> @@ -57,6 +57,11 @@ extern int of_dma_get_range(struct device_node *np,
>>>>> u64 *dma_addr,
>>>>>                               u64 *paddr, u64 *size);
>>>>>    extern bool of_dma_is_coherent(struct device_node *np);
>>>>>    #else /* CONFIG_OF_ADDRESS */
>>>>> +static inline u64 of_translate_address(struct device_node *np, const
>>>>> __be32 *addr)
>>>>> +{
>>>>> +    return 0;
>>>>
>>>> Maybe return OF_BAD_ADDR ?
>>>
>>> The thing to really do on sparc, is just return the address raw
>>> untranslated
>>> because that just works.
>>>
>>
>> We still need to check #address-cells, right?
>>
>> Something like this?
>>
>> static inline u64 of_translate_address(struct device_node *np, const
>> __be32 *addr)
>> {
>> #if defined(CONFIG_SPARC) || defined(CONFIG_M68K)
>> 	int pna = of_n_addr_cells(np);
>> 	u64 ret = be32_to_cpu(addr[pna - 1]);
>>
>> 	if (pna > 1)
>> 		ret += (u64)be32_to_cpu(addr[pna - 2]) << 32;
>>
>> 	return ret;
> 
> That suggests that sparc would need a translation after all, which
> seems to contradict what David said earlier.

It's not being translated, the code above is just figuring out what size
the object in the property is.
