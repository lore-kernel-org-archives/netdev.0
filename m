From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/6] net: sched: introduce a TRAP control action
Date: Mon, 5 Jun 2017 21:59:05 +0200
Message-ID: <20170605195905.GD1986@nanopsycho>
References: <20170605143832.7025-1-jiri@resnulli.us>
 <20170605143832.7025-2-jiri@resnulli.us>
 <20170605195632.GA9339@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, edumazet@google.com,
        alexander.h.duyck@intel.com, stephen@networkplumber.org,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33351 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751178AbdFET7I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:59:08 -0400
Received: by mail-wr0-f195.google.com with SMTP id v104so8444455wrb.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:59:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170605195632.GA9339@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 05, 2017 at 09:56:32PM CEST, andrew@lunn.ch wrote:
>> On Mon, Jun 05, 2017 at 04:38:27PM +0200, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>> 
>> There is need to instruct the HW offloaded path to push certain matched
>> packets to cpu/kernel for further analysis. So this patch introduces a
>> new TRAP control action to TC.
>> 
>> For kernel datapath, this action does not make much sense. So with the
>> same logic as in HW, new TRAP behaves similar to STOLEN. The skb is just
>> dropped in the datapath (and virtually ejected to an upper level, which
>> does not exist in case of kernel).
>> 
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> Reviewed-by: Yotam Gigi <yotamg@mellanox.com>
>> ---
>>  include/uapi/linux/pkt_cls.h | 5 +++++
>>  net/core/dev.c               | 2 ++
>>  net/sched/cls_bpf.c          | 1 +
>>  net/sched/sch_atm.c          | 1 +
>>  net/sched/sch_cbq.c          | 1 +
>>  net/sched/sch_drr.c          | 1 +
>>  net/sched/sch_dsmark.c       | 1 +
>>  net/sched/sch_fq_codel.c     | 1 +
>>  net/sched/sch_hfsc.c         | 1 +
>>  net/sched/sch_htb.c          | 1 +
>>  net/sched/sch_multiq.c       | 1 +
>>  net/sched/sch_prio.c         | 1 +
>>  net/sched/sch_qfq.c          | 1 +
>>  net/sched/sch_sfb.c          | 1 +
>>  net/sched/sch_sfq.c          | 1 +
>>  15 files changed, 20 insertions(+)
>> 
>> diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>> index edf43dd..5d6f711 100644
>> --- a/include/uapi/linux/pkt_cls.h
>> +++ b/include/uapi/linux/pkt_cls.h
>> @@ -37,6 +37,11 @@ enum {
>>  #define TC_ACT_QUEUED		5
>>  #define TC_ACT_REPEAT		6
>>  #define TC_ACT_REDIRECT		7
>> +#define TC_ACT_TRAP		8 /* For hw path, this means "trap to cpu",
>> +				   * for sw path, this is equivalent of
>> +				   * TC_ACT_STOLEN - drop the skb and act
>> +				   * like everything is allright.
>> +				   */
>
>Hi Jiri
>
>Given my question and your answer, can we please extend this
>description.
>
>"For hw path, this means "trap to cpu" and don't further process the
>frame in hardware."

Okay :)


>
>Oh, and s/allright/alright.

English is an odd language :) Thanks!
