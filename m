From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] Xen backend support for paged out grant targets V4.
Date: Fri, 21 Sep 2012 16:05:21 -0400
Message-ID: <20120921200521.GA20408@phenom.dumpdata.com>
References: <1347632819-13684-1-git-send-email-andres@lagarcavilla.org>
 <1347869865.14977.15.camel@zakaz.uk.xensource.com>
 <5B5132A4-93B2-41D0-B1A6-048810565DB5@gridcentric.ca>
 <20120921185258.GA4931@phenom.dumpdata.com>
 <ACFBD23A-6B32-47F3-B71A-37F4557FDE47@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Lagar-Cavilla <andreslc@gridcentric.ca>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Andres Lagar-Cavilla <andres@lagarcavilla.org>,
	xen-devel <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	David Miller <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andres Lagar-Cavilla <andres.lagarcavilla@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ACFBD23A-6B32-47F3-B71A-37F4557FDE47@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 21, 2012 at 03:30:01PM -0400, Andres Lagar-Cavilla wrote:
> On Sep 21, 2012, at 2:52 PM, Konrad Rzeszutek Wilk wrote:
>=20
> > On Mon, Sep 17, 2012 at 05:29:24AM -0400, Andres Lagar-Cavilla wrot=
e:
> >> On Sep 17, 2012, at 4:17 AM, Ian Campbell wrote:
> >>=20
> >>> (I think I forgot to hit send on this on Friday, sorry. Also
> >>> s/xen.lists.org/lists.xen.org in the CC line=E2=80=A6)
> >> I'm on a roll here=E2=80=A6
> >>=20
> >>>=20
> >>> On Fri, 2012-09-14 at 15:26 +0100, Andres Lagar-Cavilla wrote:
> >>>> Since Xen-4.2, hvm domains may have portions of their memory pag=
ed out. When a
> >>>> foreign domain (such as dom0) attempts to map these frames, the =
map will
> >>>> initially fail. The hypervisor returns a suitable errno, and kic=
ks an
> >>>> asynchronous page-in operation carried out by a helper. The fore=
ign domain is
> >>>> expected to retry the mapping operation until it eventually succ=
eeds. The
> >>>> foreign domain is not put to sleep because itself could be the o=
ne running the
> >>>> pager assist (typical scenario for dom0).
> >>>>=20
> >>>> This patch adds support for this mechanism for backend drivers u=
sing grant
> >>>> mapping and copying operations. Specifically, this covers the bl=
kback and
> >>>> gntdev drivers (which map foregin grants), and the netback drive=
r (which copies
> >>>=20
> >>>                          foreign
> >>>=20
> >>>> foreign grants).
> >>>>=20
> >>>> * Add a retry method for grants that fail with GNTST_eagain (i.e=
=2E because the
> >>>> target foregin frame is paged out).
> >>>=20
> >>>         foreign
> >>>=20
> >>>> * Insert hooks with appropriate wrappers in the aforementioned d=
rivers.
> >>>>=20
> >>>> The retry loop is only invoked if the grant operation status is =
GNTST_eagain.
> >>>> It guarantees to leave a new status code different from GNTST_ea=
gain. Any other
> >>>> status code results in identical code execution as before.
> >>>>=20
> >>>> The retry loop performs 256 attempts with increasing time interv=
als through a
> >>>> 32 second period. It uses msleep to yield while waiting for the =
next retry.
> >>> [...]
> >>>> Signed-off-by: Andres Lagar-Cavilla <andres@lagarcavilla.org>
> >>>=20
> >>> Acked-by: Ian Campbell <ian.campbell@citrix.com>
> >>>=20
> >>> Since this is more about grant tables than netback this should pr=
obably
> >>> go via Konrad rather than Dave, is that OK with you Dave?
> >>=20
> >> If that is the case hopefully Konrad can deal with the two typos? =
Otherwise happy to re-spin the patch.
> >=20
> > So with this patch when I launch an PVHVM guest on Xen 4.1 I get th=
is
> > in the initial domain and the guest is crashed:
> >=20
> > [  261.927218] privcmd_fault: vma=3Dffff88002a31dce8 7f4edc095000-7=
f4edc195000, pgoff=3Dc8, uv=3D00007f4edc15d000
>=20
> With this patch? Or with the mmapbatch v2? This is a page fault in a =
foreign-mapped VMA. Not touched by this grant backend patch we are talk=
ing about.

This patch. But I also had a modified blkback. So let me double check
that it is not the persistent grants and this patch doing something nau=
ghty.

>=20
> Does the hypervisor dump anything to its console?
>=20
> At which point during xc_hvm_build do you see this? (or elsewhere in =
the toolstack?)

No idea. Didn't examine that much.
