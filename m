From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Fri, 29 May 2009 08:03:30 +0000
Message-ID: <20090529080330.GB5483@ff.dom.local>
References: <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp> <20090529074812.GA5483@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:26982 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbZE2IDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:03:37 -0400
Received: by yx-out-2324.google.com with SMTP id 3so3255477yxj.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 01:03:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090529074812.GA5483@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 07:48:12AM +0000, Jarek Poplawski wrote:
> On 29-05-2009 07:18, Minoru Usui wrote:
...
> > I investigated this problem, and I found a bug in tc_ctl_tfilter() in net/sched/cls_api.c.
> > 
> > When 'tc filter add' command is executed and proto-tcf does not exist, 
> > tcf_ctl_tfilter() allocates, initializes and chanins proto-tcf(tp) to
> > cops->tcf_chain()'s chain before calling tp->ops->change().
> > 
> > If tp->ops->change() returns an error, tcf_ctl_tfilter() returns an error
> > too, but proto-tcf(tp) is not unchained yet. 
> > 
> > I think tcf_ctl_tfilter() shouldn't chain proto-tcf to the chain before it returns
> > an error.
> 
> I didn't verify this too much, so I might be wrong, but it looks like
> cls_cgroup_classify() does things a bit different than others (doesn't
> check the 'head' etc. for NULL), so maybe you should consider fixing
> it instead? (Btw., the tc classifier maintainer added to Cc).

OOPS! Others mostly don't check this either, so my suggestion was wrong.

Sorry,
Jarek P.
