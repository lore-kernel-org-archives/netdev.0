From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
Subject: Re: [patch] sunrpc: add missing return statement
Date: Tue, 4 May 2010 23:02:26 +0900
Message-ID: <201005042302.BGH82397.FJVOFSOLQOMFHt@I-love.SAKURA.ne.jp>
References: <20100504115759.266396633@emlix.com>
	<1272976042.7559.24.camel@localhost.localdomain>
	<201005042203.DAJ09881.tFQOJFHSOLVOMF@I-love.SAKURA.ne.jp>
	<1272978815.7559.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jw-QdrG9jWwCLEAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, batsakis-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1272978815.7559.27.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Trond Myklebust wrote:
> > > No. It should either be a BUG_ON(), or else be removed entirely.
> > > Returning an error value for something that is clearly a programming bug
> > > is not a particularly useful exercise...
> > > 
> > Removing NULL check is wrong because it will NULL pointer dereference later.
> 
> Wrong. Removing NULL check is _right_ because calling this function
> without setting up a back channel first is a major BUG. Returning an
> error value to the user is pointless, since the user has no control over
> this. It is entirely under control of the sunrpc developers...
> 
For security people, removing

	if (!args->bc_xprt)
		ERR_PTR(-EINVAL);

is worse and changing to

	BUG_ON(!args->bc_xprt);

is better.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
