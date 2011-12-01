From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [GIT PULL v2] Open vSwitch
Date: Thu, 1 Dec 2011 16:24:18 +0900
Message-ID: <20111201072418.GA18436@verge.net.au>
References: <20111123075433.GA7928@gondor.apana.org.au>
	<1322050976.2039.125.camel@mojatatu>
	<20111128130409.GB16828@gondor.apana.org.au>
	<0199E0D51A61344794750DC57738F58E7586A74137@GVW1118EXC.americas.hpqcorp.net>
	<20111128145157.GA17678@gondor.apana.org.au>
	<CAEP_g=_Mj9az1oSLzUcqT_m05JEJavjcQ1SFeoYtsgk5xvBjBQ@mail.gmail.com>
	<20111130070219.GB32630@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, "Fischer,
	Anna" <anna.fischer-VXdhtT5mjnY@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org" <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111130070219.GB32630-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
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

On Wed, Nov 30, 2011 at 03:02:19PM +0800, Herbert Xu wrote:
> On Tue, Nov 29, 2011 at 10:21:32PM -0800, Jesse Gross wrote:
> >
> > It's userspace which is managing the entries in the kernel hash table
> > and it has some intelligence about aging out entries (and specifically
> > about doing it more aggressively as the number of entries increases),
> > so it's not really unbounded.  In practice, userspace actually keeps
> > the number of entries much smaller than the maximum size of the table.
> 
> Right, I thought you would have something like this.
> 
> But I think you still need to rehash the table periodically, as
> otherwise even with a limited number of entries and attacker could
> construct long chains in a hash bucket, given enough time.

I have done some work on both testing and improving the performance
of Open vSwitch with large number of flows (for some definition of large).

My current opinion is that expanding the hash table beyond its current
maximum size does not seem to yield a performance benefit.  This is
primarily because there are other performance issues that come into play
first - in particular the rate at which a dump of statistics for all flows
is made (I intend to fix this, its a user-space problem).

So while I agree that optimizing the hash is a good idea.  I don't believe
it is a bottle-neck at this point. Though I could be convinced otherwise if
long collision chains could be constructed with relatively few flows.
Something I had not considered until I rad your email just now.
