From: Flavio Leitner <fleitner@redhat.com>
Subject: Re: [PATCH v2] e1000e: convert to stats64
Date: Fri, 21 Jan 2011 15:03:40 -0200
Message-ID: <20110121170340.GA3087@redhat.com>
References: <1292358735-32089-1-git-send-email-fleitner@redhat.com>
	<1292362173.2478.6.camel@edumazet-laptop>
	<20101216123131.GA3070@redhat.com>
	<AANLkTi=y4u1DTtOX9-70CeDGhWGu4bBKK0Y32Js41=bK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <AANLkTi=y4u1DTtOX9-70CeDGhWGu4bBKK0Y32Js41=bK@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, Dec 16, 2010 at 07:14:35PM -0800, Jeff Kirsher wrote:
> On Thu, Dec 16, 2010 at 04:31, Flavio Leitner <fleitner@redhat.com> wrote:
> > On Tue, Dec 14, 2010 at 10:29:33PM +0100, Eric Dumazet wrote:
> >> Le mardi 14 d=E9cembre 2010 =E0 18:32 -0200, Flavio Leitner a =E9crit :
> >> > Provides accurate stats at the time user reads them.
> >> >
> >> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> >> > ---
> >> > =A0drivers/net/e1000e/e1000.h =A0 | =A0 =A05 ++-
> >> > =A0drivers/net/e1000e/ethtool.c | =A0 27 +++++++++-------
> >> > =A0drivers/net/e1000e/netdev.c =A0| =A0 68 ++++++++++++++++++++++++-=
----------------
> >> > =A03 files changed, 59 insertions(+), 41 deletions(-)
> >> >
> >> > diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
> >> > index fdc67fe..5a5e944 100644
> >> > --- a/drivers/net/e1000e/e1000.h
> >> > +++ b/drivers/net/e1000e/e1000.h
> >> > @@ -363,6 +363,8 @@ struct e1000_adapter {
> >> > =A0 =A0 /* structs defined in e1000_hw.h */
> >> > =A0 =A0 struct e1000_hw hw;
> >> >
> >> > + =A0 spinlock_t stats64_lock;
> >> > + =A0 struct rtnl_link_stats64 stats64;
> >>
> >> I am not sure why you add this stats64 in e1000_adapter ?
> >>
> >> Why isnt it provided by callers (automatic variable, or provided to
> >> ndo_get_stats64()). I dont see accumulators, only a full rewrite of th=
is
> >> structure in e1000e_update_stats() ?
> >
> > Good point. I have modified the patch to fix that.
> > thanks!
> >
> > From 3487bd7dacd0c23bba315270139dab6e00e5ff02 Mon Sep 17 00:00:00 2001
> > From: Flavio Leitner <fleitner@redhat.com>
> > Date: Thu, 16 Dec 2010 10:26:03 -0200
> > Subject: [PATCH] e1000e: convert to stats64
> >
> > Provides accurate stats at the time user reads them.
> >
> > Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> > ---
> > =A0drivers/net/e1000e/e1000.h =A0 | =A0 =A03 ++
> > =A0drivers/net/e1000e/ethtool.c | =A0 25 ++++++++-------
> > =A0drivers/net/e1000e/netdev.c =A0| =A0 68 ++++++++++++++++++++++++++++=
+++++--------
> > =A03 files changed, 70 insertions(+), 26 deletions(-)
> >
> =

> I have dropped you previous version of the patch and applied v2 to my
> tree for review and testing.
> Thanks Flavio!

Hi Jeff,

Do you have any feedback on this patch?
thanks,
-- =

Flavio

---------------------------------------------------------------------------=
---
Special Offer-- Download ArcSight Logger for FREE (a $49 USD value)!
Finally, a world-class log management solution at an even better price-free!
Download using promo code Free_Logger_4_Dev2Dev. Offer expires =

February 28th, so secure your free ArcSight Logger TODAY! =

http://p.sf.net/sfu/arcsight-sfd2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
