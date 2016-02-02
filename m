From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/8] be2net: SRIOV Queue distribution should
 factor in EQ-count of VFs
Date: Tue, 2 Feb 2016 19:41:51 +0300
Message-ID: <56B0DC4F.9010700@cogentembedded.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
 <1454408435-11575-5-git-send-email-sriharsha.basavapatna@broadcom.com>
 <56B0BD98.50809@cogentembedded.com>
 <CAHHeUGV-q3Q-E60rOzfzH3c-PVAqgiDK6gJMFn3DfhE4DO8QPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34472 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932401AbcBBQly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 11:41:54 -0500
Received: by mail-lf0-f47.google.com with SMTP id j78so52633240lfb.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 08:41:54 -0800 (PST)
In-Reply-To: <CAHHeUGV-q3Q-E60rOzfzH3c-PVAqgiDK6gJMFn3DfhE4DO8QPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2016 06:41 PM, Sriharsha Basavapatna wrote:

>>> The SRIOV resource distribution logic for RX/TX queue counts is not
>>> optimal
>>> when a small number of VFs are enabled. It does not take into account the
>>> VF's EQ count while computing the queue counts. Because of this, the VF
>>> gets a large number of queues, though it doesn't have sufficient EQs,
>>> resulting in wasted queue resources. And the PF gets a smaller share of
>>> queues though it has more EQs. Fix this by capping the VF queue count at
>>> its EQ count.
>>>
>>> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
>>> ---
>>>    drivers/net/ethernet/emulex/benet/be.h      |  4 ++++
>>>    drivers/net/ethernet/emulex/benet/be_main.c | 15 ++++++---------
>>>    2 files changed, 10 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/emulex/benet/be.h
>>> b/drivers/net/ethernet/emulex/benet/be.h
>>> index cf83783..f33d73c 100644
>>> --- a/drivers/net/ethernet/emulex/benet/be.h
>>> +++ b/drivers/net/ethernet/emulex/benet/be.h
>>> @@ -89,6 +89,10 @@
>>>    #define BE3_MAX_TX_QS         16
>>>    #define BE3_MAX_EVT_QS                16
>>>    #define BE3_SRIOV_MAX_EVT_QS  8
>>> +#define        SH_VF_MAX_NIC_EQS       3       /* Skyhawk VFs can have a
>>> max of 4 EQs
>>
>>
>>     Other #define's seem to have a space after them, not tab...
>
> Thanks for catching it,  I'll fix it in a subsequent patch ?

    Please just don't use tab here, no need for new patch.

> Thanks,
> -Harsha

[...]

MBR, Sergei
