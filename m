From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Fri, 1 Sep 2017 07:11:11 -0700
Message-ID: <20170901141111.GE1599492@devbig577.frc2.facebook.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <20170826024957.m5ita6usxihywmdd@ast-mbp>
 <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
 <20170831142201.GB1599492@devbig577.frc2.facebook.com>
 <20170901032754.ogqmgqaqp3dwfdbw@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
        daniel@iogearbox.net, ast@kernel.org, davem@davemloft.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:38843 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751985AbdIAOLR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 10:11:17 -0400
Received: by mail-qt0-f172.google.com with SMTP id w42so1496997qtg.5
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 07:11:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170901032754.ogqmgqaqp3dwfdbw@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Alexei.

On Thu, Aug 31, 2017 at 08:27:56PM -0700, Alexei Starovoitov wrote:
> > > The 2 flags are completely independent. The existing override logic is
> > > unchanged. If a program can not be overridden, then the new recursive
> > > flag is irrelevant.
> > 
> > I'm not sure all four combo of the two flags makes sense.  Can't we
> > have something simpler like the following?
> > 
> > 1. None: No further bpf programs allowed in the subtree.
> > 
> > 2. Overridable: If a sub-cgroup installs the same bpf program, this
> >    one yields to that one.
> > 
> > 3. Recursive: If a sub-cgroup installs the same bpf program, that
> >    cgroup program gets run in addition to this one.
> > 
> > Note that we can have combinations of overridables and recursives -
> > both allow further programs in the sub-hierarchy and the only
> > distinction is whether that specific program behaves when that
> > happens.
> 
> If I understand the proposal correctly in case of:
> A (with recurs) -> B (with override) -> C (with recurse) -> D (with override)
> when something happens in D, you propose to run D,C,A  ?

Yes, B gets overridden by C, so the effective progarms are A, C and D.

> With the order of execution from children to parent?

Hmm... I'm not sure about the execution ordering.  How these programs
chain would be dependent on the type of the program, right?  Would we
be able to use the same chaining order for all types of programs?

> That's a bit a different then what I was proposing with 'multi-prog' flag,
> but the more I think about it the more I like it.

Great.

> In your case detach is sort of transparent to everything around.
> And you would also allow to say 'None' to one of the substrees too, right?
> So something like:
> A (with recurs) -> B (with override) -> C (with recurse) -> D (None) -> E
> would mean that E cannot attach anything and events in E will
> call D->C->A, right?

Yeap.

Thanks.

-- 
tejun
