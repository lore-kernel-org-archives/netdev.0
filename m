From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 07:56:34 -0400
Message-ID: <1243684594.3966.89.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	 <1243604796.3966.21.camel@dogo.mojatatu.com>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	 <20090530114506.GA3166@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <mi.usui@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f130.google.com ([209.85.221.130]:62920 "EHLO
	mail-qy0-f130.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbZE3L5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 07:57:32 -0400
Received: by qyk36 with SMTP id 36so453705qyk.33
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 04:57:33 -0700 (PDT)
In-Reply-To: <20090530114506.GA3166@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-05-30 at 13:45 +0200, Jarek Poplawski wrote:

> > > >       }
> > > >
> > > >       err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
> > > > -     if (err == 0)
> > > > +     if (err == 0) {
> > > > +             if (n->nlmsg_type == RTM_NEWTFILTER &&
> > > > +                 (n->nlmsg_flags&NLM_F_CREATE)) {
> 
> Since "tc filter replace" uses this type and flag too without creating
> tp, this check is not enough. I guess we could simply use a variable
> like tp_created etc. 

It will be superfluos. 
tp_created is the check
n->nlmsg_type == RTM_NEWTFILTER && n->nlmsg_flags&NLM_F_CREATE
replace will be
n->nlmsg_type == RTM_NEWTFILTER && n->nlmsg_flags & NLM_F_EXCL

> Anyway, changing this place looks tricky to me,
> so maybe it would be safer to do a separate cls_cgroup fix just for
> -stable, and this one patch for -next only?

I think they are two separate issues.
The fact that we dont destroy an allocated tp on failure is an issue
regardless of what cls_group does. In the case of Minoru's issue
it is because he is misconfiguring cls_group.

cheers,
jamal



