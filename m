From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next v3 2/2] net: core: introduce mini_Qdisc and
 eliminate usage of tp->q for clsact fastpath
Date: Wed, 1 Nov 2017 09:11:14 -0700
Message-ID: <20171101161112.hpzl2a5oi5tdvauo@ast-mbp>
References: <20171031151222.5021-1-jiri@resnulli.us>
 <20171031151222.5021-3-jiri@resnulli.us>
 <20171101021248.624bvt5jcqr37w5e@ast-mbp>
 <20171101081803.GB1977@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, edumazet@google.com,
        daniel@iogearbox.net, alexander.h.duyck@intel.com,
        willemb@google.com, john.fastabend@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:45279 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751682AbdKAQLZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 12:11:25 -0400
Received: by mail-pg0-f65.google.com with SMTP id b192so2496888pga.2
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 09:11:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171101081803.GB1977@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 01, 2017 at 09:18:03AM +0100, Jiri Pirko wrote:
> Wed, Nov 01, 2017 at 03:12:50AM CET, alexei.starovoitov@gmail.com wrote:
> >On Tue, Oct 31, 2017 at 04:12:22PM +0100, Jiri Pirko wrote:
> >> From: Jiri Pirko <jiri@mellanox.com>
> >> 
> >> In sch_handle_egress and sch_handle_ingress tp->q is used only in order
> >> to update stats. So stats and filter list are the only things that are
> >> needed in clsact qdisc fastpath processing. Introduce new mini_Qdisc
> >> struct to hold those items. Also, introduce a helper to swap the
> >> mini_Qdisc structures in case filter list head changes.
> >> 
> >> This removes need for tp->q usage without added overhead.
> >> 
> >> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> >> ---
> >> v2->v3:
> >> - Using head change callback to replace miniq pointer every time tp head
> >>   changes. This eliminates one rcu dereference and makes the claim "without
> >>   added overhead" valid.
> >
> >you kidding, right?
> >It's still two loads.
> 
> I'm not.
> I replace:
> 
> one rcu_dereference_bh(dev->egress_cl_list)
> 	by one rcu_dereference_bh(dev->miniq_egress)
> 
> one dereference cl->q
> 	by one dereference miniq->filter_list
> 
> What do I miss?

that in assembler code they are the same when debug is off ?
