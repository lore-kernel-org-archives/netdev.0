From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] tipc: Use the appropriate swab helper rather than an
	internal helper
Date: Tue, 12 Aug 2008 21:23:59 -0700
Message-ID: <1218601440.30194.108.camel@brick>
References: <1218587234.30194.93.camel@brick>
	 <20080812205422.4273d598.akpm@linux-foundation.org>
	 <1218600348.30194.105.camel@brick>
	 <20080812212017.febf1392.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	per.liden@ericsson.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:34899 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbYHMEX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 00:23:59 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1094826yxm.1
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2008 21:23:58 -0700 (PDT)
In-Reply-To: <20080812212017.febf1392.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-08-12 at 21:20 -0700, Andrew Morton wrote:
> On Tue, 12 Aug 2008 21:05:47 -0700 Harvey Harrison <harvey.harrison@gmail.com> wrote:
> 
> > ___generally means I am an internal implementation detail, don't use
> > me.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > ---
> > Sorry for breaking the build Andrew, my testing has been with all the __constant
> > versions in-tree removed.
> > 
> >  net/tipc/subscr.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
> > index 0326d30..f5da05d 100644
> > --- a/net/tipc/subscr.c
> > +++ b/net/tipc/subscr.c
> > @@ -85,7 +85,7 @@ static struct top_srv topsrv = { 0 };
> >  
> >  static u32 htohl(u32 in, int swap)
> >  {
> > -	return swap ? (u32)___constant_swab32(in) : in;
> > +	return swap ? (u32)swab32(in) : in;
> >  }
> 
> yes, that's what I did too, only I dropped the
> seems-to-me-to-be-unneeded (u32) cast.

I made the mistake of folding this bit into the series that removes all
users of the __constant_ helpers as I forgot it was a build breaker.
That's why I wasn't seeing it here.

Harvey

