From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Allocate RX and TX queues in alloc_netdev_mq
Date: Thu, 28 Oct 2010 11:08:23 -0700
Message-ID: <AANLkTik0rO5wcMtvoys__p07deATp0wUjDx=24oLYcfS@mail.gmail.com>
References: <alpine.DEB.1.00.1010281036350.22486@pokey.mtv.corp.google.com>
	<20101028.104942.179929434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:62778 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753828Ab0J1SI0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 14:08:26 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o9SI8Ppv006670
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 11:08:25 -0700
Received: from yxm34 (yxm34.prod.google.com [10.190.4.34])
	by kpbe14.cbf.corp.google.com with ESMTP id o9SI8IBp032266
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 11:08:24 -0700
Received: by yxm34 with SMTP id 34so1599026yxm.14
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 11:08:23 -0700 (PDT)
In-Reply-To: <20101028.104942.179929434.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 10:49 AM, David Miller <davem@davemloft.net> wr=
ote:
> From: Tom Herbert <therbert@google.com>
> Date: Thu, 28 Oct 2010 10:45:45 -0700 (PDT)
>
>> Both TX and RX queue allocations in the netdev structure had been mo=
ved
>> to register_device with the idea that the number of queues could be
>> changed between device allocation and registration. =A0It was determ=
ined
>> that changing the num_queues after the call to alloc_netdev_mq was n=
ot
>> a good idea, so that was abandoned. =A0Also, some drivers call
>> netif_queue_start without registering device, which causes panic
>> when dev->_tx queue structure is accessed. =A0This patch moves queue
>> allocations back to alloc_netdev_mq to fix these issues.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>
> Changing the TX queue state with a netif_stop_queue() call or
> similar was always completely pointless and frankly a bug.
>
> So that should not influence the motivation behind this change
> at all.
>
> In fact I _like_ that it crashes now so that we are forced
> to fix these cases.
>
> Really, the queue state is absolutely immaterial during
> device allocation and registration. =A0It's state is
> %100 "don't care" until ->open() is invoked.
>
> So any code that touches the queue state at these earlier points in
> time is completely extraneous if not broken.
>
