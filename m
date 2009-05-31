From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 10:07:03 +0200
Message-ID: <20090531080703.GB2756@ami.dom.local>
References: <20090529225929.GD2753@ami.dom.local> <b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com> <20090530114506.GA3166@ami.dom.local> <1243684594.3966.89.camel@dogo.mojatatu.com> <20090530120750.GB3166@ami.dom.local> <1243686683.3966.117.camel@dogo.mojatatu.com> <20090530124554.GC3166@ami.dom.local> <1243688628.3966.126.camel@dogo.mojatatu.com> <b10243b50905301522t42aafaffxbf5934388af3df93@mail.gmail.com> <1243725194.3966.162.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Minoru Usui <mi.usui@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:46362 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbZEaIHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 04:07:23 -0400
Received: by fxm12 with SMTP id 12so5179687fxm.37
        for <netdev@vger.kernel.org>; Sun, 31 May 2009 01:07:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1243725194.3966.162.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2009 at 07:13:14PM -0400, jamal wrote:
> On Sun, 2009-05-31 at 07:22 +0900, Minoru Usui wrote:
> 
> > I'll do it after understanding above code.
> 
> Current patch has two places with:
> 
> +               if (n->nlmsg_type == RTM_NEWTFILTER &&
> +                   (n->nlmsg_flags&NLM_F_CREATE)) {
> 
> The change (in the two spots) is:
> +               if (n->nlmsg_type == RTM_NEWTFILTER &&
> +                   (n->nlmsg_flags&(NLM_F_CREATE|NLM_F_EXCL))) {
> 

Sorry, but I don't think this change is enough; tc filter replace
with only this (n->nlmsg_type == RTM_NEWTFILTER &&
(n->nlmsg_flags&(NLM_F_CREATE))) can get here with an "old" tp
and will relink it or destroy depending on the ->change() return.

Cheers,
Jarek P.
