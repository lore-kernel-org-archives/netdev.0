From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ] net_sched: actions - Add default lookup
Date: Sun, 03 Nov 2013 23:12:32 -0500 (EST)
Message-ID: <20131103.231232.1438716028901698864.davem@davemloft.net>
References: <5270ECB5.2030601@mojatatu.com>
	<1383141605.4857.38.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org, ebiederm@xmission.com,
	alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280Ab3KDEMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Nov 2013 23:12:34 -0500
In-Reply-To: <1383141605.4857.38.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Oct 2013 07:00:05 -0700

> On Wed, 2013-10-30 at 07:25 -0400, Jamal Hadi Salim wrote:
>> Attached. Tested with simple action.
>> 
>> cheers,
>> jamal
> 
> Why not setting .lookup to tcf_hash_search
> in the few actions not already doing that ?
> 
> This would be more consistent.
> # git grep -n tcf_hash_search
> include/net/act_api.h:92:int tcf_hash_search(struct tc_action *a, u32 index);
> net/sched/act_api.c:198:int tcf_hash_search(struct tc_action *a, u32 index)
> net/sched/act_api.c:209:EXPORT_SYMBOL(tcf_hash_search);
> net/sched/act_csum.c:588:       .lookup         = tcf_hash_search,
> net/sched/act_gact.c:209:       .lookup         =       tcf_hash_search,
> net/sched/act_ipt.c:301:        .lookup         =       tcf_hash_search,
> net/sched/act_ipt.c:315:        .lookup         =       tcf_hash_search,
> net/sched/act_mirred.c:274:     .lookup         =       tcf_hash_search,
> net/sched/act_nat.c:311:        .lookup         =       tcf_hash_search,
> net/sched/act_pedit.c:246:      .lookup         =       tcf_hash_search,
> net/sched/act_police.c:410:     .lookup         =       tcf_hash_search,

Right, and BUG() if we try to register and action with a NULL .lookup
member.
