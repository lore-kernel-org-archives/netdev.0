From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] tc: m_xt: Fix segfault with iptables-1.6.0
Date: Thu, 12 Jan 2017 22:09:36 +0100
Message-ID: <20170112210935.GH6774@orbyte.nwl.cc>
References: <20170112142249.13041-1-phil@nwl.cc>
 <20170112113449.581e2219@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59347 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750730AbdALVJi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 16:09:38 -0500
Content-Disposition: inline
In-Reply-To: <20170112113449.581e2219@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 11:34:49AM -0800, Stephen Hemminger wrote:
> On Thu, 12 Jan 2017 15:22:49 +0100
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > Said iptables version introduced struct xtables_globals field
> > 'compat_rev', a function pointer. Initializing it is mandatory as
> > libxtables calls it without existence check.
> > 
> > Without this, tc segfaults when using the xt action like so:
> > 
> > | tc filter add dev d0 parent ffff: u32 match u32 0 0 \
> > |	action xt -j MARK --set-mark 20
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> > ---
> >  tc/m_xt.c | 3 +++
> >  1 file changed, 3 insertions(+)
> > 
> > diff --git a/tc/m_xt.c b/tc/m_xt.c
> > index dbb54981462ee..57ed40d7aa3a8 100644
> > --- a/tc/m_xt.c
> > +++ b/tc/m_xt.c
> > @@ -77,6 +77,9 @@ static struct xtables_globals tcipt_globals = {
> >  	.orig_opts = original_opts,
> >  	.opts = original_opts,
> >  	.exit_err = NULL,
> > +#if (XTABLES_VERSION_CODE >= 11)
> > +	.compat_rev = xtables_compatible_revision,
> > +#endif
> >  };
> >  
> >  /*
> 
> Ah the xtables API is not really an application friendly API by
> any stretch of the imagination

Yeah, this could have really been handled by the lib, especially since
it provides the callback to assign to it. But whatever, looking at the
git log shows it's not happening for the first time so at least it's
consistent. :)

> Parenthesis not really necessary there.

Oh, indeed! I just stuck to how the other XTABLES_VERSION_CODE checks
are made. Are you going to apply this patch either way? I'll then
follow-up dropping the parentheses at all places at once.

Thanks, Phil
