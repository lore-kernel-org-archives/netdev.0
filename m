From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 1/1] net_sched fix: reclassification needs to
 consider ether protocol changes
Date: Tue, 16 Feb 2016 07:12:40 -0500
Message-ID: <56C31238.3070807@mojatatu.com>
References: <1455565749-30951-1-git-send-email-jhs@emojatatu.com>
 <56C23C29.2060101@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35919 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934AbcBPMMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 07:12:47 -0500
Received: by mail-ig0-f181.google.com with SMTP id xg9so71571333igb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 04:12:47 -0800 (PST)
In-Reply-To: <56C23C29.2060101@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-15 03:59 PM, Daniel Borkmann wrote:
> On 02/15/2016 08:49 PM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> actions could change the etherproto in particular with ethernet
>> tunnelled data. Typically such actions, after peeling the outer header,
>> will ask for the packet to be  reclassified. We then need to restart
>> the classification with the new proto header.
>>
>> Example setup used to catch this:
>> sudo tc qdisc add dev $ETH ingress
>> sudo tc filter add dev $ETH parent ffff: prio 2 protocol 0xbeef \
>> u32 match u32 0 0 flowid 1:1 \
>> action ife decode reclassify
>
> ife action is out of tree, but I believe this should be possible with
> vlan action and using reclassify as tc opcode.
>

Ok, let me do some test with vlan example.(Note: Caught this when i was
trying to test the IFE code for submission on the flight home).

>> Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
>> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Has kbuild bot issues, I'd probably just move this under 'reset' label,
> like:
>
 >
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index b5c2cf2..af1acf0 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -1852,6 +1852,7 @@ reset:
>       }
>
>       tp = old_tp;
> +    protocol = tc_skb_protocol(skb);
>       goto reclassify;
>   #endif
>   }


The polite bot is confused in its report. I had to look at .config to
figure it out. I guess this is the point where human intervention is
needed. Basically the problem is it turned off CONFIG_NET_CLS_ACT
and recompiled; for a second i thought it was i386 specific.
I will juggle things around to make it happy.

cheers,
jamal


> Thanks,
> Daniel
