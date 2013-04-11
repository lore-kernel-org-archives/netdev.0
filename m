From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH 1/4] Add packet recirculation
Date: Thu, 11 Apr 2013 09:14:58 +0900
Message-ID: <20130411001457.GE1205@verge.net.au>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
	<1365403431-18102-2-git-send-email-horms@verge.net.au>
	<CAEP_g=9nj24hZcA-czzuz3xaweATxRxmibuFaqODTSoPmRmHsw@mail.gmail.com>
	<20130409075024.GG11444@verge.net.au>
	<CAEP_g=-baZGttBowXKGdgKafxp9fkUrQ=44y562ZzfnOL-XaQg@mail.gmail.com>
	<20130410091657.GA27777@verge.net.au>
	<CAEP_g=8vE9Ykdnro+Puw34ORRnPEMn1LMBxv+f7w_Dp-uty_iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAEP_g=8vE9Ykdnro+Puw34ORRnPEMn1LMBxv+f7w_Dp-uty_iw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Wed, Apr 10, 2013 at 09:21:23AM -0700, Jesse Gross wrote:
> On Wed, Apr 10, 2013 at 2:16 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> > On Tue, Apr 09, 2013 at 08:44:02AM -0700, Jesse Gross wrote:
> >> On Tue, Apr 9, 2013 at 12:50 AM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> >> > On Mon, Apr 08, 2013 at 06:46:29PM -0700, Jesse Gross wrote:
> >> >> On Sun, Apr 7, 2013 at 11:43 PM, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org> wrote:
> >> >> > diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
> >> >> > index 47830c1..5129da1 100644
> >> >> > --- a/ofproto/ofproto-dpif.c
> >> >> > +++ b/ofproto/ofproto-dpif.c
> >> >>
> >> >> I'm still working on more detailed comments for this.  However, I'm
> >> >> concerned about whether the behavior for revalidation and stats is
> >> >> correct.
> >> >
> >> > I am a little concerned about that too.
> >> > Perhaps Ben could look over it?
> >>
> >> To rephrase, there are problems in both of those areas. Validation in
> >> particular I don't think handles resubmitted facets and I believe that
> >> stats on rules will be the sum of all resubmitted passes.
> >
> > Some questions:
> > By resubmitted do you mean recirculated?
> 
> Yes.
> 
> > What is the stats behaviour that you would like?
> 
> A given rule should have byte and packet counts equal to the number of
> times it is matched (i.e. the first time) even if we have to decompose
> it into multiple passes internally.
> 
> > With regards to validation, I assume the area of concern
> > is around facet_revalidate(). I will look into that.
> 
> Yes.
> 
> >> Both of these will likely significantly affect the data structures, so
> >> please look into this before we go further.
> >
> > Sure. I was not planning to push (much) further until this series
> > is reviewed properly.
> 
> I'm planning on waiting on further reviews of this file until you've
> had a chance to look into validation and stats since I think that may
> change some of the data structures.

Sure, I assumed as much.

I'll try and prepare and post a version with those issues, and the other
ones you raised elsewhere in your review, in the not to distant future.
