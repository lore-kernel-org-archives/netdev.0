From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/3][NET] gen_estimator: list_empty() check in
	est_timer() fixed
Date: Mon, 21 Jan 2008 07:34:55 +0100
Message-ID: <20080121063455.GA981@ff.dom.local>
References: <20080120234959.GB2691@ami.dom.local> <20080120155544.0a071675@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:38045 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724AbYAUG2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 01:28:21 -0500
Received: by nf-out-0910.google.com with SMTP id g13so221406nfb.21
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2008 22:28:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080120155544.0a071675@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 20, 2008 at 03:55:44PM -0800, Stephen Hemminger wrote:
> On Mon, 21 Jan 2008 00:49:59 +0100
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > This patch changes the method of checking for empty list in est_timer():
> > list_empty() is not recommended for RCU protected lists. Now, it's simply
> > a variable used for this.
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > 
> > ---
> > 
> > diff -Nurp 2.6.24-rc8-mm1-p1-/net/core/gen_estimator.c 2.6.24-rc8-mm1-p1+/net/core/gen_estimator.c
> > --- 2.6.24-rc8-mm1-p1-/net/core/gen_estimator.c	2008-01-20 20:58:35.000000000 +0100
> > +++ 2.6.24-rc8-mm1-p1+/net/core/gen_estimator.c	2008-01-20 21:07:42.000000000 +0100
> > @@ -106,6 +106,7 @@ static void est_timer(unsigned long arg)
> >  {
> >  	int idx = (int)arg;
> >  	struct gen_estimator *e;
> > +	int list_not_empty = 0;
> 
> Using a negative name for what is a boolean value leads
> to code that reads like a double negative sentence. Better to choose
> a variable name that is direct, can't use list_empty because that
> is a macro, so how about "estimator_found".
> 

Hmm, seems right, but since just after sending this patch I started
to doubt this 2/3 patch could really matter here, I'll maybe wait with
this name change for some confirmation yet.

So, since it certainly doesn't matter for 1/3 and 3/3 I withdraw this
2/3 patch for now.

BTW, I've forgotten to mention with patch 1/3 that this checking with
warning on gen_new_estimator() double call should be only temporary,
and after more testing gen_estimator structure could be probably
decreased after removing bstats and rate_est fields.

Thanks,
Jarek P.
