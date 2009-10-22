From: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 0/5] Candidate fix for increased number of GFP_ATOMIC
	failures V2
Date: Thu, 22 Oct 2009 17:03:10 +0100
Message-ID: <20091022160310.GS11778@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <84144f020910220747nba30d8bkc83c2569da79bd7c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>, Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>,
	Sven Geggus <lists-+AJD3D7QEjjt/htJsj1pd9AswbaBtrod@public.gmane.org>,
	Karol Lewandowski <karol.k.lewandowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kalle.valo-X3B1VOXEql0@public.gmane.org>,
	David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Mohamed Abbas <mohamed.abbas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jens Axboe <jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3Sm6D+HspMUB@public.gmane.org
To: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <84144f020910220747nba30d8bkc83c2569da79bd7c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2009 at 05:47:10PM +0300, Pekka Enberg wrote:
> On Thu, Oct 22, 2009 at 5:22 PM, Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org> wrote:
> > Test 1: Verify your problem occurs on 2.6.32-rc5 if you can
> >
> > Test 2: Apply the following two patches and test again
> >
> > =A01/5 page allocator: Always wake kswapd when restarting an alloca=
tion attempt after direct reclaim failed
> > =A02/5 page allocator: Do not allow interrupts to use ALLOC_HARDER
>=20
> These are pretty obvious bug fixes and should go to linux-next ASAP I=
MHO.
>=20

Agreed, but I wanted to pin down where exactly we stand with this
problem before sending patches any direction for merging.

> > Test 5: If things are still screwed, apply the following
> > =A05/5 Revert 373c0a7e, 8aa7e847: Fix congestion_wait() sync/async =
vs read/write confusion
> >
> > =A0 =A0 =A0 =A0Frans Pop reports that the bulk of his problems go a=
way when this
> > =A0 =A0 =A0 =A0patch is reverted on 2.6.31. There has been some con=
fusion on why
> > =A0 =A0 =A0 =A0exactly this patch was wrong but apparently the conv=
ersion was not
> > =A0 =A0 =A0 =A0complete and further work was required. It's unknown=
 if all the
> > =A0 =A0 =A0 =A0necessary work exists in 2.6.31-rc5 or not. If there=
 are still
> > =A0 =A0 =A0 =A0allocation failures and applying this patch fixes th=
e problem,
> > =A0 =A0 =A0 =A0there are still snags that need to be ironed out.
>=20
> As explained by Jens Axboe, this changes timing but is not the source
> of the OOMs so the revert is bogus even if it "helps" on some
> workloads. IIRC the person who reported the revert to help things did
> report that the OOMs did not go away, they were simply harder to
> trigger with the revert.
>=20

IIRC, there were mixed reports as to how much the revert helped.  I'm h=
oping
that patches 1+2 cover the bases hence why I asked them to be tested on
their own. Patch 2 in particular might be responsible for watermarks be=
ing
impacted enough to cause timing problems. I left reverting with patch 5=
 as
a standalone test to see how much of a factor the timing changes introd=
uced
are if there are still allocation problems.

--=20
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
