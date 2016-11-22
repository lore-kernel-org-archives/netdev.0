From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net] bnxt: do not busy-poll when link is down
Date: Tue, 22 Nov 2016 10:55:53 -0800
Message-ID: <CACKFLik9rvPfSh1ppcTtjS-bbgsOh4hKJCEaXkCN46eb5_fhpA@mail.gmail.com>
References: <1479838448-44877-1-git-send-email-gospo@broadcom.com> <1479839916.8455.439.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Gospodarek <gospo@broadcom.com>,
        Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:35896 "EHLO
        mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755713AbcKVSzy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 13:55:54 -0500
Received: by mail-vk0-f43.google.com with SMTP id p9so20398188vkd.3
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 10:55:54 -0800 (PST)
In-Reply-To: <1479839916.8455.439.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2016 at 10:38 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-11-22 at 13:14 -0500, Andy Gospodarek wrote:
>> When busy polling while a link is down (during a link-flap test), TX
>> timeouts were observed as well as the following messages in the ring
>> buffer:
>>
>> bnxt_en 0008:01:00.2 enP8p1s0f2d2: Resp cmpl intr err msg: 0x51
>> bnxt_en 0008:01:00.2 enP8p1s0f2d2: hwrm_ring_free tx failed. rc:-1
>> bnxt_en 0008:01:00.2 enP8p1s0f2d2: Resp cmpl intr err msg: 0x51
>> bnxt_en 0008:01:00.2 enP8p1s0f2d2: hwrm_ring_free rx failed. rc:-1
>>
>> These were resolved by checking for link status and returning if link
>> was not up.
>>
>> Signed-off-by: Andy Gospodarek <gospo@broadcom.com>
>> Signed-off-by: Michael Chan <michael.chan@broadcom.com>
>> Tested-by: Rob Miller <rob.miller@broadcom.com>
>> ---
>>  drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
>> index e18635b..013e373 100644
>> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
>> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
>> @@ -1811,6 +1811,9 @@ static int bnxt_busy_poll(struct napi_struct *napi)
>>       if (atomic_read(&bp->intr_sem) != 0)
>>               return LL_FLUSH_FAILED;
>>
>> +     if (!bp->link_info.link_up)
>> +             return LL_FLUSH_FAILED;
>> +
>>       if (!bnxt_lock_poll(bnapi))
>>               return LL_FLUSH_BUSY;
>>
>
>
> Any plans removing this busy polling stuff, now it is done in core
> networking stack ?
>
> This would remove bnxt_lock_napi() extra overhead in normal path ( napi
> poll )
>
> I could do this but I do not have the hardware to do the tests.
>
It's on my list of many TODO things.  Probably in the next few weeks.
