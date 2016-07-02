From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 1/2] net: pktgen: support injecting packets for
 qdisc testing
Date: Sat, 2 Jul 2016 14:12:01 -0700
Message-ID: <57782E21.3070703@gmail.com>
References: <20160629194731.14745.20562.stgit@john-Precision-Tower-5810>
 <5774F2A6.3020308@mojatatu.com> <57754E6E.8010602@gmail.com>
 <5776686B.5090204@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33974 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbcGBVMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 17:12:13 -0400
Received: by mail-pa0-f42.google.com with SMTP id bz2so48115114pad.1
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 14:12:13 -0700 (PDT)
In-Reply-To: <5776686B.5090204@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-07-01 05:56 AM, Jamal Hadi Salim wrote:
> On 16-06-30 12:53 PM, John Fastabend wrote:
>> On 16-06-30 03:21 AM, Jamal Hadi Salim wrote:
>>> On 16-06-29 03:47 PM, John Fastabend wrote:
> 
>>
>> Taking a look at the link couple differences exist. First the patch
>> linked does a 'netif_xmit_frozen_or_drv_stopped(txq)' check but this
>> really shouldn't be needed it is handled by the sch_direct_xmit()
>> logic in ./net/sched
>>
>> Also in this patch I made it way more conservative on when to back
>> off then my original patch and now its closer to the one linked except
>> I also back off with return code NET_XMIT_CN.
>>
>> As for clones what is the concern exactly? We allow them through the
>> ingress pktgen mode that can hit classifiers and I don't see any issues
>> testing with them.
>>
> 
> I sent you that because we discussed back then and you thought
> there was something different and useful.
> I dont remember why it was important to avoid clones - maybe i had a
> bug. I thought we discussed it (I will try to dig into the machine
> used for testing).
> Anyways, doesnt matter if you tested and it works fine.

Ah I was originally ignoring more of the error cases and continuing to
try and enqueue packets into the qdisc even though it was returning
error codes. You suggested we should abort in the error case and I
adopted your idea in this patch.

.John

> 
> cheers,
> jamal
> 
