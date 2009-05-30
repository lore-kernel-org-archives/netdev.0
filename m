From: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sat, 30 May 2009 08:31:23 -0400
Message-ID: <1243686683.3966.117.camel@dogo.mojatatu.com>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090529141830.8ba30a24.usui@mxm.nes.nec.co.jp>
	<1243604796.3966.21.camel@dogo.mojatatu.com>
	<1243605269.3966.28.camel@dogo.mojatatu.com>
	<20090529225929.GD2753@ami.dom.local>
	<b10243b50905300417v3e208ad8s78936f106175e51@mail.gmail.com>
	<20090530114506.GA3166@ami.dom.local>
	<1243684594.3966.89.camel@dogo.mojatatu.com>
	<20090530120750.GB3166@ami.dom.local>
Reply-To: hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090530120750.GB3166-dUp/P3zyUuaNj9Bq2fkWzw@public.gmane.org>
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

On Sat, 2009-05-30 at 14:07 +0200, Jarek Poplawski wrote:
> On Sat, May 30, 2009 at 07:56:34AM -0400, jamal wrote:

> > tp_created is the check
> > n->nlmsg_type == RTM_NEWTFILTER && n->nlmsg_flags&NLM_F_CREATE
> > replace will be
> > n->nlmsg_type == RTM_NEWTFILTER && n->nlmsg_flags & NLM_F_EXCL
> 
> Hmm... Probably I miss something, but I've just seen this prink during
> tc filter replace with:
> 
> err = tp->ops->change();
> if (n->nlmsg_type == RTM_NEWTFILTER && (n->nlmsg_flags&NLM_F_CREATE))
> 	printk(...);

That sounds right. 
Remeber, you could have NLM_F_EXCL|NLM_F_CREATE to indicate "create this
thing if it doesnt exist; if it exists  it is an error"
If it doesnt exist we will enter that (tp == NULL) path
also fh will be 0 ==> So you will never enter the code
path you are refering to.
If it exists (i.e you found it) and you enter the code path you refer
to, then you surely dont want to destroy it if NLM_F_EXCL is set.

> > I think they are two separate issues.
> > The fact that we dont destroy an allocated tp on failure is an issue
> > regardless of what cls_group does. In the case of Minoru's issue
> > it is because he is misconfiguring cls_group.
> 
> Sure, but we don't want people to get oops in such a case, I guess.
> 

The ops is caused by the code fixed in the patch - did i miss something?

cheers,
jamal
