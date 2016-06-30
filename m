From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 1/2] net: pktgen: support injecting packets for
 qdisc testing
Date: Thu, 30 Jun 2016 09:53:02 -0700
Message-ID: <57754E6E.8010602@gmail.com>
References: <20160629194731.14745.20562.stgit@john-Precision-Tower-5810>
 <5774F2A6.3020308@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35103 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbcF3QyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 12:54:10 -0400
Received: by mail-oi0-f65.google.com with SMTP id d132so8410909oig.2
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 09:53:12 -0700 (PDT)
In-Reply-To: <5774F2A6.3020308@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-30 03:21 AM, Jamal Hadi Salim wrote:
> On 16-06-29 03:47 PM, John Fastabend wrote:
>> Add another xmit_mode to pktgen to allow testing xmit functionality
>> of qdiscs. The new mode "queue_xmit" injects packets at
>> __dev_queue_xmit() so that qdisc is called.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---

[...]

> 
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> In travel mode, dont have much cycles right now - but can you review
> again:
> http://www.spinics.net/lists/netdev/msg359545.html
> I think you should disallow clone for example and i wasnt sure if you
> covered all error scenarios etc.
> 

Taking a look at the link couple differences exist. First the patch
linked does a 'netif_xmit_frozen_or_drv_stopped(txq)' check but this
really shouldn't be needed it is handled by the sch_direct_xmit()
logic in ./net/sched

Also in this patch I made it way more conservative on when to back
off then my original patch and now its closer to the one linked except
I also back off with return code NET_XMIT_CN.

As for clones what is the concern exactly? We allow them through the
ingress pktgen mode that can hit classifiers and I don't see any issues
testing with them.

.John

> cheers,
> jamal
