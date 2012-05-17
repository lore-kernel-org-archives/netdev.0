From: Sekhar Nori <nsekhar@ti.com>
Subject: Re: [PATCH v3 4/7] ARM: davinci: net: davinci_emac: add OF support
Date: Thu, 17 May 2012 12:51:00 +0530
Message-ID: <4FB4A6DC.20208@ti.com>
References: <1330945804-3379-1-git-send-email-hs@denx.de> <1330945804-3379-5-git-send-email-hs@denx.de> <DF0F476B391FA8409C78302C7BA518B63EA14401@DBDE01.ent.ti.com> <4FB49B7B.60506@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Wolfgang Denk <wd@denx.de>, Anatoly Sivov <mm05@mail.ru>
To: <hs@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:56957 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761213Ab2EQHV2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 03:21:28 -0400
In-Reply-To: <4FB49B7B.60506@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/17/2012 12:02 PM, Heiko Schocher wrote:
> Nori, Sekhar wrote:
>> On Mon, Mar 05, 2012 at 16:40:01, Heiko Schocher wrote:

>>> +#ifdef CONFIG_OF
>>> +static struct emac_platform_data
>>> +	*davinci_emac_of_get_pdata(struct platform_device *pdev,
>>> +	struct emac_priv *priv)
>>> +{
>>> +	struct device_node *np;
>>> +	struct device_node *pinmux_np;
>>> +	struct emac_platform_data *pdata = NULL;
>>> +	const u8 *mac_addr;
>>> +	u32 data;
>>> +	int ret;
>>> +	int version;
>>> +
>>> +	np = pdev->dev.of_node;
>>> +	if (!np)
>>> +		goto nodata;
>>> +	else
>>> +		version = EMAC_VERSION_2;
>>
>> You could set pdata->version directly here. 
> 
> done.

Just noticed that pdata is not setup at this time. I guess you will be
moving around some code to do this.

>>> +
>>> +	pinmux_np = of_parse_phandle(np, "pinmux-handle", 0);
>>> +	if (pinmux_np)
>>> +		davinci_cfg_reg_of(pinmux_np);
>>
>> This is a DaVinci specific pinmux function and this
>> driver can be used in non-DaVinci platforms like C6x
>> and OMAP. So, it will not be correct to call a DaVinci
>> specific function here.
> 
> Ah, right!
> 
>> Can you drop the pinmux from this patch for now? On DaVinci,
> 
> Done ... Hmm.. so I think, I should drop this for all patches
> from my patchset, right?

Yes.

> 
>> for pinmux, we need to migrate to drivers/pinctrl/ as well.
> 
> Ah, I see ... take a look at it, maybe I find time to do here
> something ... or do you know about work in progress here?

There is no work in progress within TI. So, if you are interested in
taking a stab it it, it will be great.

> 
>> Doing this will also make this patch independent of the rest
>> of this series can even be merged separately. Can you please
>> make these changes and resend just this patch?
> 
> Yep, I do some test with the changes you requested and resend
> this patch ... do you prefer some tree, which I should use as
> base?

This one should ideally merge through the network subsystem so may be
base it on the net-next tree?

http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=summary

Thanks,
Sekhar
