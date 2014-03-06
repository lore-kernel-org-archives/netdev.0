From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 2/2] 6lowpan: reassembly: fix kernel oops while
 unloading
Date: Thu, 6 Mar 2014 17:41:35 +0100
Message-ID: <20140306164135.GD17526@breakpoint.cc>
References: <1394052211-6976-1-git-send-email-alex.aring@gmail.com>
 <1394052211-6976-3-git-send-email-alex.aring@gmail.com>
 <20140305223246.GA17526@breakpoint.cc>
 <20140306060943.GB13676@omega>
 <20140306133851.GC17526@breakpoint.cc>
 <20140306163635.GA21460@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40884 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751276AbaCFQlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 11:41:36 -0500
Content-Disposition: inline
In-Reply-To: <20140306163635.GA21460@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Aring <alex.aring@gmail.com> wrote:
> ah, ok.
> 
> > I am currently testing this fix:
> > 
> > diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> > index 322dceb..3b01959 100644
> > --- a/net/ipv4/inet_fragment.c
> > +++ b/net/ipv4/inet_fragment.c
> > @@ -208,7 +208,7 @@ int inet_frag_evictor(struct netns_frags *nf, struct
> > 		inet_frags *f, bool force)
> >         }
> >  
> >         work = frag_mem_limit(nf) - nf->low_thresh;
> > -       while (work > 0) {
> > +       while (work > 0 || force) {
> > 
> > 
> 
> I looked at this and try my little testscript and I don't get the kernel
> oops also. What's the next step?

Thanks for testing!

I'll make official submit soon, adding proper changelog and your
tested-by tag.
