From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [RFC] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 14:42:09 +0100
Message-ID: <87txq6g0jy.fsf@nemi.mork.no>
References: <1359023152-32576-1-git-send-email-bjorn@mork.no>
	<1809412.hrq33TVdWp@linux-5eaq.site> <87y5fig32r.fsf@nemi.mork.no>
	<2556579.vjYlY1iKn5@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2556579.vjYlY1iKn5-7ztolUikljGernLeA6q8OA@public.gmane.org> (Oliver Neukum's message of
	"Thu, 24 Jan 2013 14:12 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:

> On Thursday 24 January 2013 13:47:40 Bj=C3=B8rn Mork wrote:
>> Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:
>> > On Thursday 24 January 2013 12:22:54 Bj=C3=B8rn Mork wrote:
>> >
>> >> Sorry for being daft, but how do I code the "20 among the last 30=
" part
>> >> there?
>> >
>> > Just by agreeing that you can live with false negatives but not fa=
lse positives
>> >
>> > if (++counter > 30) {
>> > 	counter =3D bogus =3D 0;
>> > } else {
>> > 	if (is_bogus(packet)
>> > 		bogus++;
>> > 	if (bogus > counter/2)
>
> Should probably be something like bogus > counter/2 + 10

right

>> > 		throttle();
>> > }
>>=20
>> So, add two new counters to struct usbnet for this?  That seems a li=
ttle
>> overkill to me, but I don't see how else to implement anything like =
that.
>
> Memory is cheap.

OK

>> It is still not completely clear to me how the throttling/unthrottli=
ng
>> should be done.  It tested with static counters (to avoid having to
>> rebuild everything for this test) and a new EVENT_RX_THROTTLE flag.
>> Still on top of my previous patch just for safety while testing, as =
I am
>> fed up of having to reboot all the time :-)
>>=20
>> Doing the flag test in rx_submit seems simpler than trying to track =
all
>> the places this is called.  Still checking the dev->done.qlen to be =
able
>> to unthrottle.
>
> Ideally we would do some error handling. Does the device keep spewing
> zero packets for all eternity?

Yes. The only way to get rid of the bug once it has triggered seems to
be powering the device off/on.  So unthrottling is not important for
this device.  But I guess it will be for other devices with more
temporary problems.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
