From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 14:45:54 +0200
Message-ID: <20090530124554.GC3166@ami.dom.local>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp> <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp> <1243604796.3966.21.camel@dogo.mojatatu.com> <1243605269.3966.28.camel@dogo.mojatatu.com> <20090529225929.GD2753@ami.dom.local> <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com> <20090530114506.GA3166@ami.dom.local> <1243684594.3966.89.camel@dogo.mojatatu.com> <20090530120750.GB3166@ami.dom.local> <1243686683.3966.117.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Minoru Usui <mi.usui@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:37329 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754666AbZE3MrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 08:47:08 -0400
Received: by bwz22 with SMTP id 22so6617571bwz.37
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 05:47:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1243686683.3966.117.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2009 at 08:31:23AM -0400, jamal wrote:
> On Sat, 2009-05-30 at 14:07 +0200, Jarek Poplawski wrote:
> > On Sat, May 30, 2009 at 07:56:34AM -0400, jamal wrote:
> 
> > > tp_created is the check
> > > n->nlmsg_type == RTM_NEWTFILTER && n->nlmsg_flags&NLM_F_CREATE
> > > replace will be
> > > n->nlmsg_type == RTM_NEWTFILTER && n->nlmsg_flags & NLM_F_EXCL
> > 
> > Hmm... Probably I miss something, but I've just seen this prink during
> > tc filter replace with:
> > 
> > err = tp->ops->change();
> > if (n->nlmsg_type == RTM_NEWTFILTER && (n->nlmsg_flags&NLM_F_CREATE))
> > 	printk(...);
> 
> That sounds right. 
> Remeber, you could have NLM_F_EXCL|NLM_F_CREATE to indicate "create this
> thing if it doesnt exist; if it exists  it is an error"
> If it doesnt exist we will enter that (tp == NULL) path
> also fh will be 0 ==> So you will never enter the code
> path you are refering to.
> If it exists (i.e you found it) and you enter the code path you refer
> to, then you surely dont want to destroy it if NLM_F_EXCL is set.

I mean we don't want to link it again or destroy after ->change() err
if we run replace (n->nlmsg_type == RTM_NEWTFILTER &&
(n->nlmsg_flags&NLM_F_CREATE)).

> 
> > > I think they are two separate issues.
> > > The fact that we dont destroy an allocated tp on failure is an issue
> > > regardless of what cls_group does. In the case of Minoru's issue
> > > it is because he is misconfiguring cls_group.
> > 
> > Sure, but we don't want people to get oops in such a case, I guess.
> > 
> 
> The ops is caused by the code fixed in the patch - did i miss something?

IMHO it could be fixed "old way" in cls_group code too.

Cheers,
Jarek P.
