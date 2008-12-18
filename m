From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 07/13] dmaengine: introduce dma_request_channel and
 private channels
Date: Thu, 18 Dec 2008 14:33:29 +0000
Message-ID: <129600E5E5FB004392DDC3FB599660D70C984F6A@irsmsx504.ger.corp.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213453.32354.53002.stgit@dwillia2-linux.ch.intel.com>
	 <129600E5E5FB004392DDC3FB599660D70C8F3406@irsmsx504.ger.corp.intel.com>
 <e9c3a7c20812151555g14080561q18cf2d0db4c1813b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46300 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169AbYLROdk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 09:33:40 -0500
In-Reply-To: <e9c3a7c20812151555g14080561q18cf2d0db4c1813b@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Williams wrote:
> On Fri, Dec 12, 2008 at 7:29 AM, Sosnowski, Maciej
> <maciej.sosnowski@intel.com> wrote:
>>> +static struct dma_chan *private_candidate(dma_cap_mask_t *mask,
>>> struct dma_device *dev) +{
>>> +     struct dma_chan *chan;
>>> +     struct dma_chan *ret = NULL;
>>> +
>>> +     /* devices with multiple channels need special handling as we
>>> need to +   * ensure that all channels are either private or
>>> public. +      */ +     if (dev->chancnt > 1 &&
>>> !dma_has_cap(DMA_PRIVATE, dev->cap_mask)) +
>>> list_for_each_entry(chan, &dev->channels, device_node) { +
>>> /* some channels are already publicly allocated */ +
>>> if (chan->client_count) +                             return NULL;
>>> +             }
>>
>> Isn't it a dangerous approach to let clients consume for their
>> exclusive usage channels meant for general-purpose ("pubilc" ones)?
>> Why not to limit private_candidate to devices with DMA_PRIVATE
>> capability only?
>>
>
> This allows unused channels to be claimed by dma_request_channel().
> It is not dangerous as long as ->client_count is zero.

What about situation, where some or all "public" channels in the system
have been claimed by one client for its exclusive usage
before another client appears trying to use available "public" channels?
Despite of presence in the system of channels that supposed to be "public",
the second cilent realizes that the channels are not available anymore at all
or at least limited...
Doesn't it contradict the general idea of "public" (general purpose) channels?

Regards,
Maciej
