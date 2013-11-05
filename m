From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH ] net_sched: actions - Add default lookup
Date: Tue, 05 Nov 2013 07:19:15 -0500
Message-ID: <5278E243.3020603@mojatatu.com>
References: <5270ECB5.2030601@mojatatu.com>	<1383141605.4857.38.camel@edumazet-glaptop.roam.corp.google.com> <20131103.231232.1438716028901698864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:64986 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596Ab3KEM0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 07:26:20 -0500
Received: by mail-yh0-f44.google.com with SMTP id f10so1626568yha.3
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 04:26:20 -0800 (PST)
In-Reply-To: <20131103.231232.1438716028901698864.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Apologies for the latency
My intention was to eventually remove it everywhere since this is needed
by all actions. An action could override it, otherwise they get the
default.

cheers,
jamal

On 11/03/13 23:12, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 30 Oct 2013 07:00:05 -0700
>
>> On Wed, 2013-10-30 at 07:25 -0400, Jamal Hadi Salim wrote:
>>> Attached. Tested with simple action.
>>>
>>> cheers,
>>> jamal
>>
>> Why not setting .lookup to tcf_hash_search
>> in the few actions not already doing that ?
>>
>> This would be more consistent.
>> # git grep -n tcf_hash_search
>> include/net/act_api.h:92:int tcf_hash_search(struct tc_action *a, u32 index);
>> net/sched/act_api.c:198:int tcf_hash_search(struct tc_action *a, u32 index)
>> net/sched/act_api.c:209:EXPORT_SYMBOL(tcf_hash_search);
>> net/sched/act_csum.c:588:       .lookup         = tcf_hash_search,
>> net/sched/act_gact.c:209:       .lookup         =       tcf_hash_search,
>> net/sched/act_ipt.c:301:        .lookup         =       tcf_hash_search,
>> net/sched/act_ipt.c:315:        .lookup         =       tcf_hash_search,
>> net/sched/act_mirred.c:274:     .lookup         =       tcf_hash_search,
>> net/sched/act_nat.c:311:        .lookup         =       tcf_hash_search,
>> net/sched/act_pedit.c:246:      .lookup         =       tcf_hash_search,
>> net/sched/act_police.c:410:     .lookup         =       tcf_hash_search,
>
> Right, and BUG() if we try to register and action with a NULL .lookup
> member.
>
