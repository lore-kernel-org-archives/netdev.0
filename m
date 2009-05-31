From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 09:55:29 +0200
Message-ID: <20090531075528.GA2756@ami.dom.local>
References: <20090530114506.GA3166@ami.dom.local>
	<1243684594.3966.89.camel@dogo.mojatatu.com>
	<20090530120750.GB3166@ami.dom.local>
	<1243686683.3966.117.camel@dogo.mojatatu.com>
	<20090530124554.GC3166@ami.dom.local>
	<1243688628.3966.126.camel@dogo.mojatatu.com>
	<20090530132047.GD3166@ami.dom.local>
	<1243690297.3966.135.camel@dogo.mojatatu.com>
	<20090530140006.GE3166@ami.dom.local>
	<1243724933.3966.158.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>,
        containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1243724933.3966.158.camel-A00voryUPPswpNmlq7E/ZAC/G2K4zDHf@public.gmane.org>
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

On Sat, May 30, 2009 at 07:08:53PM -0400, jamal wrote:
> On Sat, 2009-05-30 at 16:00 +0200, Jarek Poplawski wrote:
> > On Sat, May 30, 2009 at 09:31:37AM -0400, jamal wrote:
> > > What were you suggesting to change in cls_group to avoid this oops?
> > 
> > I think checking the head (tp->root) for NULL like in cls_fw or
> > cls_route should work.
> 
> IMHO that is a workaround for the tp linking bug
> [IOW, there is no need to check for tp->root == NULL (in the fast path)
> if such an illegal tp was never linked to begin with (on the slow
> path)].
> 
> So those classifiers you point to need to be fixed afterwards (but 
> not -stable material).
> My thinking of fixing them to do proper init/get as well later.

Sure, after fixing it properly we should get rid of unneeded checks.

> > Anyway, it's worked for other classifiers like this for some time...
> 
> Would you agree that it is/was a bandaid?
> Or maybe you have some other fear that this may break something else and
> prefer the workaround instead?

If somebody decided to do it this way instead of the "proper" fix then
it looks to me more like a bandaid "by design". And, yes, I have some
fear we could break some strange configs, which could depend on this
wrong but working design.

Cheers,
Jarek P.
