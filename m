From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] at91_ether: use gpio_is_valid for phy IRQ line
Date: Fri, 25 Nov 2011 14:56:01 +0100
Message-ID: <4ECF9E71.2050305@atmel.com>
References: <1322128098-17724-1-git-send-email-jamie@jamieiles.com> <1322169674-4109-1-git-send-email-nicolas.ferre@atmel.com> <20111124222836.GB28582@gallagher> <20111125134708.GM15531@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Jamie Iles <jamie@jamieiles.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111125134708.GM15531@game.jcrosoft.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/25/2011 02:47 PM, Jean-Christophe PLAGNIOL-VILLARD :
> On 22:28 Thu 24 Nov     , Jamie Iles wrote:
>> Hi Nicolas,
>>
>> On Thu, Nov 24, 2011 at 10:21:14PM +0100, Nicolas Ferre wrote:
>>> Use the generic gpiolib gpio_is_valid() function to test
>>> if the phy IRQ line GPIO is actually provided.
>>>
>>> For non-connected or non-existing phy IRQ lines, -EINVAL
>>> value is used for phy_irq_pin field of struct at91_eth_data.
>>>
>>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>>> ---
>>>  drivers/net/ethernet/cadence/at91_ether.c |   23 +++++++++++++----------
>>>  1 files changed, 13 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
>>> index 56624d3..a1c4143 100644
>>> --- a/drivers/net/ethernet/cadence/at91_ether.c
>>> +++ b/drivers/net/ethernet/cadence/at91_ether.c
>>> @@ -255,8 +255,7 @@ static void enable_phyirq(struct net_device *dev)
>>>  	unsigned int dsintr, irq_number;
>>>  	int status;
>>>  
>>> -	irq_number = lp->board_data.phy_irq_pin;
>>> -	if (!irq_number) {
>>> +	if (!gpio_is_valid(lp->board_data.phy_irq_pin)) {
>>>  		/*
>>>  		 * PHY doesn't have an IRQ pin (RTL8201, DP83847, AC101L),
>>>  		 * or board does not have it connected.
>>> @@ -265,6 +264,7 @@ static void enable_phyirq(struct net_device *dev)
>>>  		return;
>>>  	}
>>>  
>>> +	irq_number = lp->board_data.phy_irq_pin;
>>
>> Does this need to be:
>>
>> 	irq_number = gpio_to_irq(lp->board_data.phy_irq_pin);
>>
>> and the same for the other occurrences?  Otherwise this looks like the 
>> right thing to me.
> yes

True but I prefered to separate changes. As it was not addressed like
this in the code I clung to it. I will post an additional patch on top
of this one to add the gpio_to_irq() call.

> Acked-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>

Best regards,
-- 
Nicolas Ferre
