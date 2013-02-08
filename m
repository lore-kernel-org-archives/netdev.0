From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 2/7] htb: fix values in opt dump
Date: Fri, 8 Feb 2013 17:02:16 +0100
Message-ID: <20130208160216.GA1601@minipsycho.orion>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
 <1360328327-7144-3-git-send-email-jiri@resnulli.us>
 <1360338849.28557.98.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:64217 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946666Ab3BHQCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 11:02:21 -0500
Received: by mail-ea0-f181.google.com with SMTP id i13so1713415eaa.26
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 08:02:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1360338849.28557.98.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 08, 2013 at 04:54:09PM CET, eric.dumazet@gmail.com wrote:
>On Fri, 2013-02-08 at 13:58 +0100, Jiri Pirko wrote:
>> in htb_change_class() cl->buffer and cl->buffer are stored in ns.
>> So in dump, convert them back to psched ticks.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/sched/sch_htb.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
>> index 476992c..14a83dc 100644
>> --- a/net/sched/sch_htb.c
>> +++ b/net/sched/sch_htb.c
>> @@ -1135,9 +1135,9 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
>>  	memset(&opt, 0, sizeof(opt));
>>  
>>  	opt.rate.rate = cl->rate.rate_bps >> 3;
>> -	opt.buffer = cl->buffer;
>> +	opt.buffer = PSCHED_NS2TICKS(cl->buffer);
>>  	opt.ceil.rate = cl->ceil.rate_bps >> 3;
>> -	opt.cbuffer = cl->cbuffer;
>> +	opt.cbuffer = PSCHED_NS2TICKS(cl->cbuffer);
>>  	opt.quantum = cl->quantum;
>>  	opt.prio = cl->prio;
>>  	opt.level = cl->level;
>
>Acked-by: Eric Dumazet <edumazet@google.com>
>
>Isnt it a patch for net tree (and stable) ?

That may be.

>
>A bug origin (commit id/title) is welcomed to ease stable team work.


Okay. I will repost the patchset anyway because I misspelled "peak"
(and I will probably add similar patches I did for tbf for act_police).
I will include your acks and commit id/title.

Jiri
>
>
>
