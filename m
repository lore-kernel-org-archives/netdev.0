From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH net-next] bcm87xx: Add MODULE_DEVICE_TABLE
Date: Tue, 3 Sep 2013 12:13:20 -0700
Message-ID: <522634D0.7080606@caviumnetworks.com>
References: <1378071184.25743.52.camel@deadeye.wl.decadent.org.uk> <52261D12.5000009@gmail.com> <20130903185305.GC7729@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney.cavm@gmail.com>,
	David Daney <david.daney@cavium.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0153.outbound.protection.outlook.com ([207.46.163.153]:5273
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753265Ab3ICT2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 15:28:30 -0400
In-Reply-To: <20130903185305.GC7729@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 11:53 AM, Ben Hutchings wrote:
> On Tue, Sep 03, 2013 at 10:32:02AM -0700, David Daney wrote:
>> On 09/01/2013 02:33 PM, Ben Hutchings wrote:
>>> bcm87xx currently isn't auto-loaded if built as a module.
>>>
>>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>>> ---
>>> Compile-tested only.
>>
>> Then how do you know that it does anything sensible?
>
> This is generally required in modular PHY drivers.  I was hoping you'd
> be able to say whether that it's useful or necessary for this one.


OK. I just tested the patch, and it is not sufficient to get the module 
loaded automatically.

My configuration also successfully uses drivers/net/phy/marvell.ko, so I 
think the modules.alias file is properly generated, and the auto-loading 
is working for some PHY drivers, but bcm87xx isn't detected.

I may take a look later this week, but as the patch stands, I don't 
think it should be merged.

David Daney


>
>> Other than that, it seems plausible.
>>
>> David Daney
>
> Thanks.
>
> Ben.
>
>>>
>>> Ben.
>>>
>>>   drivers/net/phy/bcm87xx.c | 7 +++++++
>>>   1 file changed, 7 insertions(+)
>>>
>>> diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
>>> index 7997895..f5b44ff 100644
>>> --- a/drivers/net/phy/bcm87xx.c
>>> +++ b/drivers/net/phy/bcm87xx.c
>>> @@ -230,4 +230,11 @@ static void __exit bcm87xx_exit(void)
>>>   }
>>>   module_exit(bcm87xx_exit);
>>>
>>> +static struct mdio_device_id __maybe_unused bcm87xx_tbl[] = {
>>> +	{ PHY_ID_BCM8706, 0xffffffff },
>>> +	{ PHY_ID_BCM8727, 0xffffffff },
>>> +	{ }
>>> +};
>>> +
>>>   MODULE_LICENSE("GPL");
>>> +MODULE_DEVICE_TABLE(mdio, bcm87xx_tbl);
>>>
>>
>
