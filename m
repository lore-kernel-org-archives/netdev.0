From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/sched: act_pedit: limit negative offset
Date: Mon, 28 Nov 2016 00:49:36 -0500 (EST)
Message-ID: <20161128.004936.2064564176474656911.davem@davemloft.net>
References: <20161127155815.10359-1-amir@vadai.me>
        <CAM_iQpX1at1w=3OfRFchn3STTDJGXj640tGetxXToR=EyddpEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, netdev@vger.kernel.org, jhs@mojatatu.com,
        ogerlitz@mellanox.com, hadarh@mellanox.com, jiri@mellanox.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbcK1Ftm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 00:49:42 -0500
In-Reply-To: <CAM_iQpX1at1w=3OfRFchn3STTDJGXj640tGetxXToR=EyddpEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sun, 27 Nov 2016 21:39:33 -0800

> On Sun, Nov 27, 2016 at 7:58 AM, Amir Vadai <amir@vadai.me> wrote:
>> Should not allow setting a negative offset that goes below the skb head.
> ...
>> diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
>> index b54d56d4959b..e79e8a88f2d2 100644
>> --- a/net/sched/act_pedit.c
>> +++ b/net/sched/act_pedit.c
>> @@ -154,8 +154,11 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
>>                         }
>>
>>                         ptr = skb_header_pointer(skb, off + offset, 4, &_data);
>> -                       if (!ptr)
>> +                       if ((unsigned char *)ptr < skb->head) {
> 
> 
> ptr returned could be &_data, which is on stack, so why this comparison
> makes sense for this case?

Indeed, this will definitely do the wrong thing when the on-stack area
passed back to ptr.
