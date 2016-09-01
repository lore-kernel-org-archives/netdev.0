From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH 2/2] net/smsc911x: Move interrupt allocation to open/stop
Date: Thu, 1 Sep 2016 15:39:31 -0500
Message-ID: <edff2872-1243-f3b1-e32c-a84290017e4a@arm.com>
References: <1472747141-15886-1-git-send-email-jeremy.linton@arm.com>
 <1472747141-15886-3-git-send-email-jeremy.linton@arm.com>
 <20160901170617.GD10951@lunn.ch>
 <8305921f-9b9a-459b-2452-7c4e63057e8f@arm.com>
 <20160901194510.GB13292@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:38496 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752063AbcIAU6w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 16:58:52 -0400
In-Reply-To: <20160901194510.GB13292@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 09/01/2016 02:45 PM, Andrew Lunn wrote:
> On Thu, Sep 01, 2016 at 01:47:44PM -0500, Jeremy Linton wrote:
>> Hi Andrew,
>>
>> 	Thanks for taking a look at this!
>>
>> On 09/01/2016 12:06 PM, Andrew Lunn wrote:
>>> Hi Jeremy
>>>
>>> Please don't add forward references. Move the function earlier in the
>>> file.
>>
>> Ok, but I thought it was a fairly large move due to further
>> dependent functions..
>
> There are a few other options, like moving smsc911x_open() rather than
> the interrupt handler.
>
> And i would suggest what ever you do, make it a separate patch. A
> patch which says: No functional changes, just move functions around as
> needed by later patches, is going to be quick and easy to review.

Yes I put it in another patch, I was busy blasting it out rather than 
checking my email...

>
>>>> +	netif_carrier_off(dev);
>>>
>>> What has this change got to do with interrupt handling?
>>
>> 	This is a whoops, it should be in the previous patch..
>
> Or a patch of its own? You also needs to be careful with ordering
> against the phy_connect.
>
>>>> @@ -2479,38 +2491,18 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
>>>> 	if (retval < 0)
>>>> 		goto out_disable_resources;
>>>>
>>>> -	/* configure irq polarity and type before connecting isr */
>>>> -	if (pdata->config.irq_polarity == SMSC911X_IRQ_POLARITY_ACTIVE_HIGH)
>>>> -		intcfg |= INT_CFG_IRQ_POL_;
>>>> -
>>>> -	if (pdata->config.irq_type == SMSC911X_IRQ_TYPE_PUSH_PULL)
>>>> -		intcfg |= INT_CFG_IRQ_TYPE_;
>>>> -
>>>> -	smsc911x_reg_write(pdata, INT_CFG, intcfg);
>>>
>>>
>>> I see these removes, but where are the adds?
>>
>>
>> 	The functionality is duplicated in open, when the IRQ handler is tested.
>
> Ah, it is obfusticated by SMC_SET_IRQ_CFG().
>
> If you say it is duplicated, how about a separate patch removing it,
> with a clear pointer to where the duplicate is.

? Well, I didn't do that part, but I'm confused by your 
SMC_SET_IRQ_CFG(). AFAIK, that is smc911x not smsc911x. The code in 
question is in smsc911x_open() following "Set interrupt deassertion to 
100uS". It looks a little different but its reprogramming the INT_CFG 
preceding the interrupt being enabled.

Really, if I were feeling brave (because this driver is used in so many 
strange pieces of hardware) I would rewrite a large portion of the 
interrupt management in this driver. I started looking at it last month, 
while looking for the mdio polling issue, because I wanted to get the 
link state changes directly. While at it I noticed the WOL functionality 
could use some attention, etc, one problem after another.
