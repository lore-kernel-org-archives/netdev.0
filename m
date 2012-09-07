From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: MBIM
Date: Fri, 07 Sep 2012 12:02:13 -0500
Message-ID: <1347037333.8913.4.camel@dcbw.foobar.com>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
	 <87ehmf36qd.fsf@nemi.mork.no> <3121990.L41g6gGrVV@linux-lqwf.site>
	 <87392u1afl.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87392u1afl.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-09-07 at 10:53 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> writes:
> > On Thursday 06 September 2012 10:17:46 Bj=C3=B8rn Mork wrote:
> >> Not really related, but I am still worrying how MBIM is going to f=
it
> >> into the usbnet model where you have a strict relation between one
> >> netdev and one USB interface.  Do you see any way usbnet could be
> >> extended to manage a list of netdevs?
> >>=20
> >> All the netdev related functions doing
> >>=20
> >>         struct usbnet           *dev =3D netdev_priv(net);
> >>=20
> >> would still work.  But all the USB related functions using dev->ne=
t to
> >> get the netdev would fail.  Maybe this will be too difficult to
> >> implement within the usbnet framework at all?
> >
> > It depends on how much support we get from upper layers.
> > You can give two IPs to an ethernet card as well.
>=20
> Yes, of course.  But I don't think that fits the MBIM model, where
> multiple independent connections (Internet, VoIP, MMS, VPN1, VPN2, et=
c)
> to different APNs will be multiplexed over the same USB endpoints.  A=
nd

Not just multiple APNs each with different IP addressing... but QoS too=
=2E
Each WWAN bearer you create may have different QoS settings.  That
bearer may also have *both* IPv4 and IPv6 addresses.  We also may want
to put the interface that bearer is tied to into a different network
namespace or container or something like that, so that the process that
requested the specific QoS doesn't have to share it with other apps,
possibly malicious ones.  Can't do that if they are all on the same
kernel network interface, AFAIK.

Dan

> to make this not fly at all: Some of these may be IPv4, some IPv6 and
> some dual stack.  You cannot support that on a single netdev.  Mixing
> them all together on the host will not do.  When the driver sees an I=
Pv6
> multicast packet (RS, ND, whatever) on the netdev, which MBIM session
> should it forward that packet too?
>=20
> If I understand MBIM correctly, we will see device configurations wit=
h
> _one_ CDC data interface carrying all data traffic for multiple devic=
e
> functions.  A MBIM driver must de-multiplex this, and each IP functio=
n
> should be routed to its own netdev IMHO.
>=20
> > It would be best if you could come up with some preliminary code
> > at least.
>=20
> Yup.  Finally got a device.  Will start playing.
>=20
>=20
> Bj=C3=B8rn
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
