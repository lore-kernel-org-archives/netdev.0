From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCH 07/13] dmaengine: introduce dma_request_channel and private channels
Date: Mon, 15 Dec 2008 16:55:06 -0700
Message-ID: <e9c3a7c20812151555g14080561q18cf2d0db4c1813b@mail.gmail.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
	 <129600E5E5FB004392DDC3FB599660D70C8F3406@irsmsx504.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:10959 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753622AbYLOXzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 18:55:08 -0500
In-Reply-To: <129600E5E5FB004392DDC3FB599660D70C8F3406@irsmsx504.ger.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 7:29 AM, Sosnowski, Maciej
<maciej.sosnowski@intel.com> wrote:
>>       clear_bit(DMA_INTERRUPT, dma_cap_mask_all.bits);
>> +     clear_bit(DMA_PRIVATE, dma_cap_mask_all.bits);
>>       clear_bit(DMA_SLAVE, dma_cap_mask_all.bits);
>
> The comment above should be updated according to this change:
> -/* 'interrupt' and 'slave' are channel capabilities, but are not
> +/* 'interrupt', 'private' and 'slave' are channel capabilities, but are not
>

ok.

>> +static struct dma_chan *private_candidate(dma_cap_mask_t *mask,
>> struct dma_device *dev) +{
>> +     struct dma_chan *chan;
>> +     struct dma_chan *ret = NULL;
>> +
>> +     /* devices with multiple channels need special handling as we need
>> to +   * ensure that all channels are either private or public.
>> +      */
>> +     if (dev->chancnt > 1 && !dma_has_cap(DMA_PRIVATE, dev->cap_mask))
>> +             list_for_each_entry(chan, &dev->channels, device_node) {
>> +                     /* some channels are already publicly allocated */
>> +                     if (chan->client_count)
>> +                             return NULL;
>> +             }
>
> Isn't it a dangerous approach to let clients consume for their exclusive usage channels
> meant for general-purpose ("pubilc" ones)?
> Why not to limit private_candidate to devices with DMA_PRIVATE capability only?
>

This allows unused channels to be claimed by dma_request_channel().
It is not dangerous as long as ->client_count is zero.

>> +
>> +     list_for_each_entry(chan, &dev->channels, device_node) {
>> +             if (!__dma_chan_satisfies_mask(chan, mask)) {
>> +                     pr_debug("%s: %s wrong capabilities\n",
>> +                              __func__, dev_name(&chan->dev));
>> +                     continue;
>> +             }
>
> As capabilities are per device, this check could be performed just once
> before list_for_each_entry(chan, &dev->channels, device_node).
>

Yes, changed.

Thanks,
Dan
