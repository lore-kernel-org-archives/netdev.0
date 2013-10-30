From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ] net_sched:  actions - Add default lookup
Date: Wed, 30 Oct 2013 07:00:05 -0700
Message-ID: <1383141605.4857.38.camel@edumazet-glaptop.roam.corp.google.com>
References: <5270ECB5.2030601@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:63534 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752180Ab3J3OAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 10:00:07 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so1419489pbc.37
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 07:00:07 -0700 (PDT)
In-Reply-To: <5270ECB5.2030601@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 07:25 -0400, Jamal Hadi Salim wrote:
> Attached. Tested with simple action.
> 
> cheers,
> jamal

Why not setting .lookup to tcf_hash_search
in the few actions not already doing that ?

This would be more consistent.
# git grep -n tcf_hash_search
include/net/act_api.h:92:int tcf_hash_search(struct tc_action *a, u32 index);
net/sched/act_api.c:198:int tcf_hash_search(struct tc_action *a, u32 index)
net/sched/act_api.c:209:EXPORT_SYMBOL(tcf_hash_search);
net/sched/act_csum.c:588:       .lookup         = tcf_hash_search,
net/sched/act_gact.c:209:       .lookup         =       tcf_hash_search,
net/sched/act_ipt.c:301:        .lookup         =       tcf_hash_search,
net/sched/act_ipt.c:315:        .lookup         =       tcf_hash_search,
net/sched/act_mirred.c:274:     .lookup         =       tcf_hash_search,
net/sched/act_nat.c:311:        .lookup         =       tcf_hash_search,
net/sched/act_pedit.c:246:      .lookup         =       tcf_hash_search,
net/sched/act_police.c:410:     .lookup         =       tcf_hash_search,
