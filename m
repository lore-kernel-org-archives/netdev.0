From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: Re: [PATCH net-next 4/8] be2net: SRIOV Queue distribution should
 factor in EQ-count of VFs
Date: Tue, 2 Feb 2016 21:11:33 +0530
Message-ID: <CAHHeUGV-q3Q-E60rOzfzH3c-PVAqgiDK6gJMFn3DfhE4DO8QPQ@mail.gmail.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
	<1454408435-11575-5-git-send-email-sriharsha.basavapatna@broadcom.com>
	<56B0BD98.50809@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38398 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933093AbcBBPle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 10:41:34 -0500
Received: by mail-wm0-f54.google.com with SMTP id p63so28814949wmp.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 07:41:34 -0800 (PST)
In-Reply-To: <56B0BD98.50809@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 2, 2016 at 8:00 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 2/2/2016 1:20 PM, Sriharsha Basavapatna wrote:
>
>> The SRIOV resource distribution logic for RX/TX queue counts is not
>> optimal
>> when a small number of VFs are enabled. It does not take into account the
>> VF's EQ count while computing the queue counts. Because of this, the VF
>> gets a large number of queues, though it doesn't have sufficient EQs,
>> resulting in wasted queue resources. And the PF gets a smaller share of
>> queues though it has more EQs. Fix this by capping the VF queue count at
>> its EQ count.
>>
>> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
>> ---
>>   drivers/net/ethernet/emulex/benet/be.h      |  4 ++++
>>   drivers/net/ethernet/emulex/benet/be_main.c | 15 ++++++---------
>>   2 files changed, 10 insertions(+), 9 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/emulex/benet/be.h
>> b/drivers/net/ethernet/emulex/benet/be.h
>> index cf83783..f33d73c 100644
>> --- a/drivers/net/ethernet/emulex/benet/be.h
>> +++ b/drivers/net/ethernet/emulex/benet/be.h
>> @@ -89,6 +89,10 @@
>>   #define BE3_MAX_TX_QS         16
>>   #define BE3_MAX_EVT_QS                16
>>   #define BE3_SRIOV_MAX_EVT_QS  8
>> +#define        SH_VF_MAX_NIC_EQS       3       /* Skyhawk VFs can have a
>> max of 4 EQs
>
>
>    Other #define's seem to have a space after them, not tab...

Thanks for catching it,  I'll fix it in a subsequent patch ?

Thanks,
-Harsha
>
>> +                                        * and at least 1 is granted to
>> either
>> +                                        * SURF/DPDK
>> +                                        */
>>
>>   #define MAX_RSS_IFACES                15
>>   #define MAX_RX_QS             32
>
> [...]
>
> MBR, Sergei
>
