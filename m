From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 3/3] devicetree: macb: Add optional property tsu-clk
Date: Mon, 14 Sep 2015 07:44:23 -0700
Message-ID: <20150914144423.GG19678@xsjsorenbubuntu>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
 <1441958258-35441-4-git-send-email-harinik@xilinx.com>
 <20150911165256.GT19678@xsjsorenbubuntu>
 <CAFcVECK=EONgqPq1jt_kti-VKXPWGVj3OSnqUvo0YcR65Z+Phg@mail.gmail.com>
 <20150914095846.0d8e2d74@bbrezillon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Harini Katakam <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org" <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Punnaiah Choudary Kalluri <punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org" <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <anirudh-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Boris Brezillon <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150914095846.0d8e2d74@bbrezillon>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-09-14 at 09:58AM +0200, Boris Brezillon wrote:
> Hi Harini,
>=20
> On Mon, 14 Sep 2015 09:39:05 +0530
> Harini Katakam <harinikatakamlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>=20
> > On Fri, Sep 11, 2015 at 10:22 PM, S=C3=B6ren Brinkmann
> > <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org> wrote:
> > > Hi Harini,
> > >
> > > On Fri, 2015-09-11 at 01:27PM +0530, Harini Katakam wrote:
> > >> Add TSU clock frequency to be used for 1588 support in macb driv=
er.
> > >>
> > >> Signed-off-by: Harini Katakam <harinik-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> > >> ---
> > >>  Documentation/devicetree/bindings/net/macb.txt |    3 +++
> > >>  1 file changed, 3 insertions(+)
> > >>
> > >> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Do=
cumentation/devicetree/bindings/net/macb.txt
> > >> index b5d7976..f7c0ea8 100644
> > >> --- a/Documentation/devicetree/bindings/net/macb.txt
> > >> +++ b/Documentation/devicetree/bindings/net/macb.txt
> > >> @@ -19,6 +19,9 @@ Required properties:
> > >>       Optional elements: 'tx_clk'
> > >>  - clocks: Phandles to input clocks.
> > >>
> > >> +Optional properties:
> > >> +- tsu-clk: Time stamp unit clock frequency used.
> > >
> > > Why are we not using the CCF and a clk_get_rate() in the driver?
> > >
> >=20
> > If the clock source was only internal, we could use this
> > approach as usual. But TSU clock can be configured to
> > come from an external clock source or internal.
>=20
> How about declaring a fixed-rate clk [1] if it comes from an external
> clk, and using a clk driver for the internal clk case?
> This way you'll be able to use the clk API (including the
> clk_get_rate() function) instead of introducing a new way to retrieve=
 a
> clk frequency.

Right. Also, Zynq does already support external clock inputs (actually,
every clock originates from some external clock/oscillator at some
point). Maybe that code needs some additions to handle the TSU clock
too. But either way, I can't see why a clock cannot be modeled using th=
e
CCF.

	S=C3=B6ren
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
