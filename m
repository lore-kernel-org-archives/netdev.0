From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH RFC] net: davinci_emac: Fix rollback of emac_dev_open()
Date: Mon, 10 Mar 2014 08:16:14 +0100
Message-ID: <851BA4133600BADF3FBB6427@[172.22.2.41]>
References: <35CC5396F7326DBE44C9C624@[172.22.2.41]>
 <130fa9cb-7e94-4698-ac3f-f987a03c0604@mary.at.omicron.at>
 <5319DB6C.8080203@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source@linux.davincidsp.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jon Ringle <jon@ringle.org>
To: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:64868 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbaCJHQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 03:16:20 -0400
Received: by mail-ea0-f171.google.com with SMTP id n15so3510145ead.30
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 00:16:18 -0700 (PDT)
In-Reply-To: <5319DB6C.8080203@ti.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On March 07, 2014 20:15 +0530 Mugunthan V N <mugunthanvnm@ti.com> wrote:

> On Friday 07 March 2014 07:37 PM, Christian Riesch wrote:
>> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
>> Cc: Prabhakar Lad <prabhakar.csengg@gmail.com>
>> Cc: Mugunthan V N <mugunthanvnm@ti.com>
>> Cc: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>
>> Hi again,
>>
>> How about this solution for fixing the rollback of emac_dev_open()?
>> Especially the change in davinci_cpdma.c, would this break anything?
>>
>> The patch applies on top of
>> [PATCH] net: davinci_emac: Replace devm_request_irq with request_irq
>>
>> Regards,
>> Christian
>>
>>  drivers/net/ethernet/ti/davinci_cpdma.c |    4 +--
>>  drivers/net/ethernet/ti/davinci_emac.c  |   44
>>  ++++++++++++++++++++----------- 2 files changed, 31 insertions(+), 17
>>  deletions(-)
>>
>> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c
>> b/drivers/net/ethernet/ti/davinci_cpdma.c index 364d0c7..88ef270 100644
>> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
>> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
>> @@ -355,7 +355,7 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
>>  	int i;
>>
>>  	spin_lock_irqsave(&ctlr->lock, flags);
>> -	if (ctlr->state != CPDMA_STATE_ACTIVE) {
>> +	if (ctlr->state == CPDMA_STATE_TEARDOWN) {
>>  		spin_unlock_irqrestore(&ctlr->lock, flags);
>>  		return -EINVAL;
>>  	}
>> @@ -891,7 +891,7 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
>>  	unsigned		timeout;
>>
>>  	spin_lock_irqsave(&chan->lock, flags);
>> -	if (chan->state != CPDMA_STATE_ACTIVE) {
>> +	if (chan->state == CPDMA_STATE_TEARDOWN) {
>>  		spin_unlock_irqrestore(&chan->lock, flags);
>>  		return -EINVAL;
>>  	}
>
> Even when in idle mode chan stop should return error.

Can you please explain? I do not see why.

I must be able to call cpdma_ctlr_stop in idle mode to free the rx 
descriptors in case ndo_open in davinci_emac.c fails. Any other ideas how 
to solve the problem addressed in the rest of the patch?

Thanks, Christian
