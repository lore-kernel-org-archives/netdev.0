From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 14:07:50 +0200
Message-ID: <20090530120750.GB3166@ami.dom.local>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	<1243604796.3966.21.camel@dogo.mojatatu.com>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	<20090530114506.GA3166@ami.dom.local>
	<1243684594.3966.89.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1243684594.3966.89.camel-A00voryUPPswpNmlq7E/ZAC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, May 30, 2009 at 07:56:34AM -0400, jamal wrote:
> On Sat, 2009-05-30 at 13:45 +0200, Jarek Poplawski wrote:
> 
> > > > >       }
> > > > >
> > > > >       err = tp->ops->change(tp, cl, t->tcm_handle, tca, &fh);
> > > > > -     if (err == 0)
> > > > > +     if (err == 0) {
> > > > > +             if (n->nlmsg_type == RTM_NEWTFILTER &&
> > > > > +                 (n->nlmsg_flags&NLM_F_CREATE)) {
> > 
> > Since "tc filter replace" uses this type and flag too without creating
> > tp, this check is not enough. I guess we could simply use a variable
> > like tp_created etc. 
> 
> It will be superfluos. 
> tp_created is the check
> n->nlmsg_type == RTM_NEWTFILTER && n->nlmsg_flags&NLM_F_CREATE
> replace will be
> n->nlmsg_type == RTM_NEWTFILTER && n->nlmsg_flags & NLM_F_EXCL

Hmm... Probably I miss something, but I've just seen this prink during
tc filter replace with:

err = tp->ops->change();
if (n->nlmsg_type == RTM_NEWTFILTER && (n->nlmsg_flags&NLM_F_CREATE))
	printk(...);

> 
> > Anyway, changing this place looks tricky to me,
> > so maybe it would be safer to do a separate cls_cgroup fix just for
> > -stable, and this one patch for -next only?
> 
> I think they are two separate issues.
> The fact that we dont destroy an allocated tp on failure is an issue
> regardless of what cls_group does. In the case of Minoru's issue
> it is because he is misconfiguring cls_group.

Sure, but we don't want people to get oops in such a case, I guess.

Cheers,
Jarek P.
