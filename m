From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH v2 3/5] drivers: net: phy: Add MDIO driver
Date: Thu, 7 Jul 2016 15:58:57 -0700
Message-ID: <CAKh23F=tHivDnenAKqvtBFLEp=GQBCAfKe7=ZHG4bLF3XJSxKg@mail.gmail.com>
References: <1464739840-21971-1-git-send-email-isubramanian@apm.com>
 <1464739840-21971-4-git-send-email-isubramanian@apm.com> <20160601011148.GD31982@lunn.ch>
 <CAKh23FmaQy8J=f-eyfBeNndz0oT5R0icvwJ3vrw1DMJnj9uv_g@mail.gmail.com>
 <20160705134950.GC5230@lunn.ch> <CAKh23FnvgWRMo=M35Mj4=a_KeUpvOoHa8stU=bSk9Y3VSRtyzQ@mail.gmail.com>
 <20160707140302.GP19800@lunn.ch> <20160707141422.GQ1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	Matthias Brugger <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160707141422.GQ1041-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Russell,

On Thu, Jul 7, 2016 at 7:14 AM, Russell King - ARM Linux
<linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org> wrote:
> On Thu, Jul 07, 2016 at 04:03:02PM +0200, Andrew Lunn wrote:
>> > Wed, Jul 06, 2016 at 04:44:44PM -0700, Iyappan Subramanian wrote:
>> > Hi Andrew,
>> >
>> > On Tue, Jul 5, 2016 at 6:49 AM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
>> > > On Mon, Jun 06, 2016 at 10:12:35AM -0700, Iyappan Subramanian wrote:
>> > >> Hi Andrew,
>> > >>
>> > >> Thanks for the review.
>> > >>
>> > >> On Tue, May 31, 2016 at 6:11 PM, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org> wrote:
>> > >> > On Tue, May 31, 2016 at 05:10:38PM -0700, Iyappan Subramanian wrote:
>> > >> >> +static int xgene_mdio_reset(struct xgene_mdio_pdata *pdata)
>> > >> >> +{
>> > >> >> +     int ret;
>> > >> >> +
>> > >> >> +     if (pdata->mdio_id == XGENE_MDIO_RGMII) {
>> > >> >> +             if (pdata->dev->of_node) {
>> > >> >> +                     clk_prepare_enable(pdata->clk);
>> > >> >> +                     clk_disable_unprepare(pdata->clk);
>> > >> >> +                     clk_prepare_enable(pdata->clk);
>> > >> >
>> > >> > Hi Iyappan
>> > >> >
>> > >> > Is that a workaround for a hardware problem? If so, i would suggest
>> > >> > adding a comment, to stop people submitting a patch simplifying it.
>> > >>
>> > >> Hardware expects this clock sequence.  I'll add comment as you suggested.
>> > >
>> > > What exactly does the hardware require? Is this a workaround for a bug
>> > > in the clock generator? Or a workaround for a bug in the MDIO device?
>> >
>> > Hardware requires a clock pulse.  There is no bug.
>>
>> And how are you guaranteeing a pulse? You enable/disable/enable
>> without any sleeps, so it could all happen within a single clock
>> cycle?
>
> It's still really not good, because it does this:
>
> - prepare + enable
> - disable + unprepare
> - prepare + enable
>
> So every time the reset function is called, the prepare and enable
> counts against the clock get incremented.  That's a bug.  This needs
> a better solution.

I'll fix this by adding disable + unprepare on the port shutdown and
resubmit the patches.

>
> --
> RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
