From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 09:03:48 -0400
Message-ID: <1243688628.3966.126.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	 <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	 <1243604796.3966.21.camel@dogo.mojatatu.com>
	 <1243605269.3966.28.camel@dogo.mojatatu.com>
	 <20090529225929.GD2753@ami.dom.local>
	 <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	 <20090530114506.GA3166@ami.dom.local>
	 <1243684594.3966.89.camel@dogo.mojatatu.com>
	 <20090530120750.GB3166@ami.dom.local>
	 <1243686683.3966.117.camel@dogo.mojatatu.com>
	 <20090530124554.GC3166@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <mi.usui@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f130.google.com ([209.85.221.130]:54535 "EHLO
	mail-qy0-f130.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbZE3NEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2009 09:04:46 -0400
Received: by qyk36 with SMTP id 36so477448qyk.33
        for <netdev@vger.kernel.org>; Sat, 30 May 2009 06:04:47 -0700 (PDT)
In-Reply-To: <20090530124554.GC3166@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-05-30 at 14:45 +0200, Jarek Poplawski wrote:
> On Sat, May 30, 2009 at 08:31:23AM -0400, jamal wrote:

> > Remeber, you could have NLM_F_EXCL|NLM_F_CREATE to indicate "create this
> > thing if it doesnt exist; if it exists  it is an error"
> > If it doesnt exist we will enter that (tp == NULL) path
> > also fh will be 0 ==> So you will never enter the code
> > path you are refering to.
> > If it exists (i.e you found it) and you enter the code path you refer
> > to, then you surely dont want to destroy it if NLM_F_EXCL is set.
> 
> I mean we don't want to link it again or destroy after ->change() err
> if we run replace (n->nlmsg_type == RTM_NEWTFILTER &&
> (n->nlmsg_flags&NLM_F_CREATE)).

excellent point: an additional flag is needed then
n->nlmsg_flags& (NLM_F_CREATE|NLM_F_EXCL).
Minoru, please add this change in the patch before testing...

> > The ops is caused by the code fixed in the patch - did i miss something?
> 
> IMHO it could be fixed "old way" in cls_group code too.

Is the code oopsing in cls_group? It didnt seem to be so to me, and
yes cls_group is quarky in its practise (but thats a separate issue)
and even if it did oops in cls_group - this change above is a memory
leak and needs to be fixed in -stable. 

cheers,
jamal

