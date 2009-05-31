From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 10:12:13 +0200
Message-ID: <20090531081213.GC2756@ami.dom.local>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp> <20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp> <1243604796.3966.21.camel@dogo.mojatatu.com> <1243605269.3966.28.camel@dogo.mojatatu.com> <20090529225929.GD2753@ami.dom.local> <1243684218.3966.83.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:51007 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756794AbZEaIMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 04:12:47 -0400
Received: by fxm12 with SMTP id 12so5181079fxm.37
        for <netdev@vger.kernel.org>; Sun, 31 May 2009 01:12:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1243684218.3966.83.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 30, 2009 at 07:50:18AM -0400, jamal wrote:
> On Sat, 2009-05-30 at 00:59 +0200, Jarek Poplawski wrote:
>   
> > ...
> >         } else {
> >                 switch (n->nlmsg_type) {
> >                 case RTM_NEWTFILTER:
> >                         err = -EEXIST;
> >                         if (n->nlmsg_flags & NLM_F_EXCL)
> >                                 goto errout;
> >                         break;
> > 
> > Probably this case needs tcf_destroy() too.
> 
> No - that if stmnt will fail if this is a new filter being
> created.

If somebody runs tc add filter with a new priority but existing handle
a newly created (and not linked now) tc would be handled with goto
errout and would leak, I guess.

Cheers,
Jarek P.
