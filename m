From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: Integration of Open vSwitch
Date: Thu, 1 Dec 2011 16:59:23 +0900
Message-ID: <20111201075923.GC18436@verge.net.au>
References: <CAEP_g=-g5g0Z30gYBDAZ8s7ACCZSy5MLJpPDxQmmc8m1wbk3tg@mail.gmail.com>
	<20111130070011.GA32630@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111130070011.GA32630-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 30, 2011 at 03:00:11PM +0800, Herbert Xu wrote:
> On Tue, Nov 29, 2011 at 10:25:34PM -0800, Jesse Gross wrote:
> > Hi Herbert and Jamal (and everyone else),
> > 
> > Sorry about starting yet another thread but the other one went in so
> > many directions that I think a lot of things got lost in it.  As I
> > mentioned before, I'd like to have a bit of a design discussion of
> > what it would look like if Open vSwitch were to use some of the
> > existing components (and really focus on just that).  There were a
> > number of suggestions made about using parts of the bridge, tc,
> > netfilter, etc. and some of them overlap or conflict so I don't quite
> > have a coherent solution in mind.  Would you guys mind walking through
> > what each of you envision it looking like?
> 
> Personally I think your patches are fine as is.
> 
> It would obviously be nice if we could refactor the code as Jamal
> suggested into classifiers/actions, which would allow us to reuse
> them elsewhere, e.g., the flow cache classifier could be merged
> with the GRO mechanism, or something even grander like the unified
> flow cache, while the using standard actions would make all
> existing actions available and generalise OVS into something
> that allows you to direct traffic at will to any destination
> in a system, without having to have a data-path object at all.
> 
> But really I don't see immediate gains that are big enough to
> warrant any actions in that direction right now.  If we really
> wanted to do that in future we can always add those classifiers
> and actions and migrate things over.
> 
> The other factor I considered is scalability.  The OVS code as is
> is not really friendly to SMP/NUMA scalability (but as Eric pointed,
> neither is the classifier/action layer).  However, if this were to
> become a problem in future I'm sure we could extend either the
> interface as is (e.g., deploying multiqueue netlink sockets), or
> migrate to something else.
> 
> So I don't really have any objections to this going into the tree.

I apologies for being rather quiet in this discussion up until now,
the only reason for which being that I have been rather busy with other things.

I have now made a few comments on some other posts with regards to
scaling of flow counts and creation rates as I have done some work
in that area recently.

But as I have been involved in Open vSwitch for a while now I feel it would
remiss of me to not (finally) publicly state that I am supportive of the
current merge effort.
