From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single CAN
 frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 17:49:34 +0200
Message-ID: <5519708E.3040002@hartkopp.net>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net> <5519429A.8050000@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:26944 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbbC3Ptm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 11:49:42 -0400
In-Reply-To: <5519429A.8050000@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.03.2015 14:33, Sergei Shtylyov wrote:
> On 3/29/2015 9:09 PM, Oliver Hartkopp wrote:
>>
>> +    /* eliminate multiple filter matches for the same skb */
>> +    if (*this_cpu_ptr(ro->uniq_skb) == oskb &&
>> +        ktime_equal(*this_cpu_ptr(ro->uniq_tstamp), oskb->tstamp)) {
>> +            return;
>
>     Over-indented.
>

I was asked about that before. AFAIK the *skb is no unique identifier over a 
longer period of time. But together with the timestamp it becomes unique.
Or do you have a better solution to detect identical skbs?

CAN skbs do not have a (rx)hash so far and I wonder if it's worth to compute 
the hash in favor to check the *skb and the timestamp here ...


>> +
>> +    ro->uniq_tstamp = alloc_percpu(ktime_t);
>> +    if (unlikely(ro->uniq_tstamp == NULL)) {
>
>     !ro->uniq_tstamp is preferred in the networking code.
>

Ok. Will change that.

Best regards,
Oliver

> [...]
>
> WBR, Sergei
>
