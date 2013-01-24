From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [RFC] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 14:12 +0100
Message-ID: <2556579.vjYlY1iKn5@linux-5eaq.site>
References: <1359023152-32576-1-git-send-email-bjorn@mork.no> <1809412.hrq33TVdWp@linux-5eaq.site> <87y5fig32r.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87y5fig32r.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 24 January 2013 13:47:40 Bj=F8rn Mork wrote:
> Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:
> > On Thursday 24 January 2013 12:22:54 Bj=F8rn Mork wrote:
> >
> >> Sorry for being daft, but how do I code the "20 among the last 30"=
 part
> >> there?
> >
> > Just by agreeing that you can live with false negatives but not fal=
se positives
> >
> > if (++counter > 30) {
> > 	counter =3D bogus =3D 0;
> > } else {
> > 	if (is_bogus(packet)
> > 		bogus++;
> > 	if (bogus > counter/2)

Should probably be something like bogus > counter/2 + 10

> > 		throttle();
> > }
>=20
> So, add two new counters to struct usbnet for this?  That seems a lit=
tle
> overkill to me, but I don't see how else to implement anything like t=
hat.

Memory is cheap.
=20
> It is still not completely clear to me how the throttling/unthrottlin=
g
> should be done.  It tested with static counters (to avoid having to
> rebuild everything for this test) and a new EVENT_RX_THROTTLE flag.
> Still on top of my previous patch just for safety while testing, as I=
 am
> fed up of having to reboot all the time :-)
>=20
> Doing the flag test in rx_submit seems simpler than trying to track a=
ll
> the places this is called.  Still checking the dev->done.qlen to be a=
ble
> to unthrottle.

Ideally we would do some error handling. Does the device keep spewing
zero packets for all eternity?

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
