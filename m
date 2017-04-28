From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v8 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 28 Apr 2017 14:21:32 +0200
Message-ID: <20170428122131.GC19353@vergenet.net>
References: <20170426110241.GA28251@vergenet.net>
 <2e09d117-60f9-97ed-9f63-c94130ddbb0c@mojatatu.com>
 <20170426130506.GF1867@nanopsycho.orion>
 <20170426.104658.547156121898948265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35655 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165230AbdD1MVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 08:21:36 -0400
Received: by mail-wm0-f52.google.com with SMTP id w64so40796457wma.0
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 05:21:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170426.104658.547156121898948265.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 10:46:58AM -0400, David Miller wrote:
> From: Jiri Pirko <jiri@resnulli.us>
> Date: Wed, 26 Apr 2017 15:05:06 +0200
> 
> > Wed, Apr 26, 2017 at 02:46:22PM CEST, jhs@mojatatu.com wrote:
> >>On 17-04-26 07:02 AM, Simon Horman wrote:
> >>> On Tue, Apr 25, 2017 at 06:04:45PM +0200, Jiri Pirko wrote:
> >>[..]
> >>
> >>> > So fix iproute2. It is always first kernel, then iproute2.
> >>> 
> >>> Perhaps I am missing the point or somehow misguided but I would expect that
> >>> if the UAPI uses BIT() it also provides BIT().
> >>
> >>There is a user of BIT() already in iproute2 (devlink). We can move
> >>the code to be more generally available for other iproute2 users.
> >>Then this UAPI change makes use of it.
> > 
> > Should be part of UAPI as well
> > I see that include/uapi/rdma/vmw_pvrdma-abi.h is using BIT macro.
> > I don't see BIT macro defined in UAPI (I thought it is). So either
> > define it there (not sure where) or just use "<<"
> 
> "BIT" is a pretty crazy small simple name to pollute into the global
> namespace, IMHO.

It sounds to me that it would be best to just use "<<" rather than
spending cycles posturing on how to add it to the UAPI. Existing users
of BIT in the UAPI could also be updated to use "<<" to avoid having
a misleading precedence in-tree.
