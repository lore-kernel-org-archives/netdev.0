From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH RFC] net: davinci_emac: Fix rollback of emac_dev_open()
Date: Thu, 13 Mar 2014 23:47:50 +0530
Message-ID: <CA+V-a8vTEriU9x4BcOy7FcT3KYbcFC=L8xdYKT4J-4Fz_+jd3g@mail.gmail.com>
References: <35CC5396F7326DBE44C9C624@172.22.2.41> <130fa9cb-7e94-4698-ac3f-f987a03c0604@mary.at.omicron.at>
 <5319DB6C.8080203@ti.com> <851BA4133600BADF3FBB6427@172.22.2.41>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	dlos <davinci-linux-open-source@linux.davincidsp.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jon Ringle <jon@ringle.org>
To: Mugunthan V N <mugunthanvnm@ti.com>,
	Christian Riesch <christian.riesch@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:54709 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754899AbaCMSSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 14:18:11 -0400
Received: by mail-vc0-f176.google.com with SMTP id lc6so1530739vcb.21
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 11:18:10 -0700 (PDT)
In-Reply-To: <851BA4133600BADF3FBB6427@172.22.2.41>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mugunthan,

On Mon, Mar 10, 2014 at 12:46 PM, Christian Riesch
<christian.riesch@omicron.at> wrote:
>
>
> --On March 07, 2014 20:15 +0530 Mugunthan V N <mugunthanvnm@ti.com> wrote:
>
>> On Friday 07 March 2014 07:37 PM, Christian Riesch wrote:
>>>
>>> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
>>> Cc: Prabhakar Lad <prabhakar.csengg@gmail.com>
>>> Cc: Mugunthan V N <mugunthanvnm@ti.com>
>>> Cc: Florian Fainelli <f.fainelli@gmail.com>
>>> ---
>>>
>>> Hi again,
>>>
>>> How about this solution for fixing the rollback of emac_dev_open()?
>>> Especially the change in davinci_cpdma.c, would this break anything?
>>>
>>> The patch applies on top of
>>> [PATCH] net: davinci_emac: Replace devm_request_irq with request_irq
>>>
>>> Regards,
>>> Christian
>>>
>>>  drivers/net/ethernet/ti/davinci_cpdma.c |    4 +--
>>>  drivers/net/ethernet/ti/davinci_emac.c  |   44
>>>  ++++++++++++++++++++----------- 2 files changed, 31 insertions(+), 17
>>>  deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c
>>> b/drivers/net/ethernet/ti/davinci_cpdma.c index 364d0c7..88ef270 100644
>>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>>> @@ -355,7 +355,7 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
>>>         int i;
>>>
>>>         spin_lock_irqsave(&ctlr->lock, flags);
>>> -       if (ctlr->state != CPDMA_STATE_ACTIVE) {
>>> +       if (ctlr->state == CPDMA_STATE_TEARDOWN) {
>>>                 spin_unlock_irqrestore(&ctlr->lock, flags);
>>>                 return -EINVAL;
>>>         }
>>> @@ -891,7 +891,7 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
>>>         unsigned                timeout;
>>>
>>>         spin_lock_irqsave(&chan->lock, flags);
>>> -       if (chan->state != CPDMA_STATE_ACTIVE) {
>>> +       if (chan->state == CPDMA_STATE_TEARDOWN) {
>>>                 spin_unlock_irqrestore(&chan->lock, flags);
>>>                 return -EINVAL;
>>>         }
>>
>>
>> Even when in idle mode chan stop should return error.
>
>
> Can you please explain? I do not see why.
>
> I must be able to call cpdma_ctlr_stop in idle mode to free the rx
> descriptors in case ndo_open in davinci_emac.c fails. Any other ideas how to
> solve the problem addressed in the rest of the patch?
>
Do you have any comments on this patch ? I have tested it on OMAP-L138 evm
and works fine. If you have none comments may be Christian can consolidate this
patch with earlier and repost it.

Thanks,
--Prabhakar Lad
