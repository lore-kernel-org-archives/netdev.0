From: Z Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH RFCv3 08/14] arm64: introduce aarch64_insn_gen_movewide()
Date: Thu, 17 Jul 2014 22:47:22 -0700
Message-ID: <CABg9mcv4t_BwcaM0qgLivDBDGEfH0FwfTAR2QjJc4+i=M58cng@mail.gmail.com>
References: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
	<1405405512-4423-9-git-send-email-zlim.lnx@gmail.com>
	<20140716161715.GU29414@arm.com>
	<20140716220422.GB18109@gup76>
	<20140717094101.GD21153@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Catalin Marinas <Catalin.Marinas@arm.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140717094101.GD21153@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(resending this email in case the first one got caught in your spam
filter. sorry.)

On Thu, Jul 17, 2014 at 10:41:02AM +0100, Will Deacon wrote:
> On Wed, Jul 16, 2014 at 11:04:22PM +0100, Zi Shen Lim wrote:
> > On Wed, Jul 16, 2014 at 05:17:15PM +0100, Will Deacon wrote:
> > > On Tue, Jul 15, 2014 at 07:25:06AM +0100, Zi Shen Lim wrote:
> > > > Introduce function to generate move wide (immediate) instructions.
[...]
> > > > +       switch (variant) {
> > > > +       case AARCH64_INSN_VARIANT_32BIT:
> > > > +               BUG_ON(shift != 0 && shift != 16);
> > > > +               break;
> > > > +       case AARCH64_INSN_VARIANT_64BIT:
> > > > +               insn |= BIT(31);
> > > > +               BUG_ON(shift != 0 && shift != 16 && shift != 32 &&
> > > > +                      shift != 48);
> > >
> > > Would be neater as a nested switch, perhaps? If you reorder the
> > > outer-switch, you could probably fall-through too and combine the shift
> > > checks.
> >
> > Not sure I picture what you had in mind... I couldn't come up with a
> > neater version with the properties you described.
> >
> > The alternative I had was using masks instead of integer values, but
> > one could argue that while neater, it could also be harder to read:
> >
> >     switch (variant) {
> >     case AARCH64_INSN_VARIANT_32BIT:
> >             BUG_ON(shift & ~BIT(4));
> >             break;
> >     case AARCH64_INSN_VARIANT_64BIT:
> >             insn |= BIT(31);
> >             BUG_ON(shift & ~GENMASK(5, 4));
> >     ...
>
> I was thinking of using nested switches, but that doesn't fall out like I
> hoped. How about:
>
>       switch (variant) {
>       case AARCH64_INSN_VARIANT_64BIT:
>               BUG_ON(shift != 32 && shift != 48);

Sorry this won't work. For example, on the valid case of shift==0,
we'll barf right here - no fallthrough.

Shall we just leave the code as is? :)


>       case AARCH64_INSN_VARIANT_32BIT:
>               BUG_ON(shift != 0 && shift != 16);
>       };
>
> ?
>
> Will
