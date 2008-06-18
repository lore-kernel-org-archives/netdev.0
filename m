From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] fs_enet: MDIO on GPIO support
Date: Wed, 18 Jun 2008 11:00:50 -0400
Message-ID: <48592322.3090201@pobox.com>
References: <200805261152.37636.laurentp@cse-semaphore.com> <200806161057.03158.laurentp@cse-semaphore.com> <20080616163400.GA13996@loki.buserror.net> <200806181648.40874.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, vbordug@ru.mvista.com,
	pantelis.antoniou@gmail.com
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48705 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582AbYFRPBA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 11:01:00 -0400
In-Reply-To: <200806181648.40874.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laurent Pinchart wrote:
> Hi Scott,
> 
> On Monday 16 June 2008 18:34, Scott Wood wrote:
>> On Mon, Jun 16, 2008 at 10:57:02AM +0200, Laurent Pinchart wrote:
>>> On Monday 26 May 2008 11:53, Laurent Pinchart wrote:
>>>> Port the fs_enet driver to support the MDIO on GPIO driver for PHY
>>>> access in addition to the mii-bitbang driver.
>>> Now that 1/2 has been applied by Jeff, could this one make it to 
>>> powerpc-next ?
>> This patch should probably go through Jeff as well...
> 
> Jeff, what's your opinion on this ?
> 
>> Acked-by: Scott Wood <scottwood@freescale.com>
>>
>>>> -	data = of_get_property(phynode, "reg", &len);
>>>> -	if (!data || len != 4)
>>>> -		goto out_put_mdio;
>>>> +	bus_id = of_get_gpio(mdionode, 0);
>>>> +	if (bus_id < 0) {
>>>> +		struct resource res;
>>>> +		ret = of_address_to_resource(mdionode, 0, &res);
>>>> +		if (ret)
>>>> +			goto out_put_mdio;
>>>> +		bus_id = res.start;
>>>> +	}
>>>>  
>>>> -	snprintf(fpi->bus_id, 16, "%x:%02x", res.start, *data);
>>>> +	snprintf(fpi->bus_id, 16, "%x:%02x", bus_id, *data);

What are the patch dependencies, if any?

My general rule is, anytime I see 80%+ of the patch dealing with 
arch-specific API functions (such as OF resource stuff), I tend to 
prefer that goes via an arch tree.

If it's a networking change, of course I'd prefer it came in my direction.

	Jeff




