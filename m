From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Thu, 31 Aug 2017 07:22:01 -0700
Message-ID: <20170831142201.GB1599492@devbig577.frc2.facebook.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
 <20170826024957.m5ita6usxihywmdd@ast-mbp>
 <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        davem@davemloft.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:37129 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdHaOWG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 10:22:06 -0400
Received: by mail-qt0-f196.google.com with SMTP id g13so601926qta.4
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 07:22:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <bb4398e5-55a3-d63e-ac4d-3f9d7e2efc02@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, David, Alexei.

Sorry about late reply.

On Sun, Aug 27, 2017 at 08:49:23AM -0600, David Ahern wrote:
> On 8/25/17 8:49 PM, Alexei Starovoitov wrote:
> > 
> >> +	if (prog && curr_recursive && !new_recursive)
> >> +		/* if a parent has recursive prog attached, only
> >> +		 * allow recursive programs in descendent cgroup
> >> +		 */
> >> +		return -EINVAL;
> >> +
> >>  	old_prog = cgrp->bpf.prog[type];
> > 
> > ... I'm struggling to completely understand how it interacts
> > with BPF_F_ALLOW_OVERRIDE.
> 
> The 2 flags are completely independent. The existing override logic is
> unchanged. If a program can not be overridden, then the new recursive
> flag is irrelevant.

I'm not sure all four combo of the two flags makes sense.  Can't we
have something simpler like the following?

1. None: No further bpf programs allowed in the subtree.

2. Overridable: If a sub-cgroup installs the same bpf program, this
   one yields to that one.

3. Recursive: If a sub-cgroup installs the same bpf program, that
   cgroup program gets run in addition to this one.

Note that we can have combinations of overridables and recursives -
both allow further programs in the sub-hierarchy and the only
distinction is whether that specific program behaves when that
happens.

Thanks.

-- 
tejun
