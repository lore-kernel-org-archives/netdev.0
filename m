From: Dan Kenigsberg <danken@redhat.com>
Subject: Re: [iproute2][PATCH] tc: mirred target: do not report non-existing
 devices
Date: Sun, 2 Sep 2012 13:41:07 +0300
Message-ID: <20120902104107.GB8982@redhat.com>
References: <1346338277-8395-1-git-send-email-danken@redhat.com>
 <1346338914.2586.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755968Ab2IBKlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2012 06:41:10 -0400
Content-Disposition: inline
In-Reply-To: <1346338914.2586.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 30, 2012 at 08:01:54AM -0700, Eric Dumazet wrote:
> On Thu, 2012-08-30 at 17:51 +0300, Dan Kenigsberg wrote:
> > Currently, if a mirred target device is removed, `tc filter show`
> > does not reveal the fact. Instead, it replaces the original name of the
> > device with the default output of ll_map:ll_idx_n2a().
> > 
> > This is unfortunate, since one cannot differ between this case and a valid
> > mirroring target device named 'if17'.
> > 
> > It seems that the original code meant to report an error message in this
> > case, but it does not, since ll_index_to_name() never returns 0. I would
> > not like to bail out in case of an error, since the user would still be
> > interested to know what are the other details of the action.
> > 
> > Signed-off-by: Dan Kenigsberg <danken@redhat.com>
> > ---
> >  lib/ll_map.c  |   13 +++++++++++++
> >  tc/m_mirred.c |   10 ++++------
> >  2 files changed, 17 insertions(+), 6 deletions(-)
> > 
> > diff --git a/lib/ll_map.c b/lib/ll_map.c
> > index 1ca781e..8ceef41 100644
> > --- a/lib/ll_map.c
> > +++ b/lib/ll_map.c
> > @@ -108,6 +108,19 @@ const char *ll_idx_n2a(unsigned idx, char *buf)
> >  	return buf;
> >  }
> >  
> > +char *ll_index_exists(unsigned idx)
> > +{
> > +	const struct ll_cache *im;
> > +
> > +	if (idx == 0)
> > +		return 0;
> > +
> > +	for (im = idxhead(idx); im; im = im->idx_next)
> > +		if (im->index == idx)
> > +			return 1;
> > +
> > +	return 0;
> > +}
> >  
> 
> I am curious to know what compiler accepted this.

It was gcc. gcc 2> /dev/null || :, to be exact.

Sorry, fixed patch follows.
