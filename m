From: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless
 ucode is loaded
Date: Wed, 13 Jul 2016 10:24:53 +0300
Message-ID: <1468394693.25088.138.camel@coelho.fi>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com>
	<CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>
	<5783E33E.7090205@redhat.com> <1468261650.20877.14.camel@intel.com>
	<57840214.8000904@redhat.com> <87eg6yav5e.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linuxwifi <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Ivgi, Chaya Rachel" <chaya.rachel.ivgi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Sharon, Sara" <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87eg6yav5e.fsf-5ukZ45wKbUHoml4zekdYB16hYfS7NtTn@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-07-13 at 09:50 +0300, Kalle Valo wrote:
> Prarit Bhargava <prarit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>=20
> > > We implement thermal zone because we do support it, but the
> > > problem is
> > > that we need the firmware to be loaded for that. So you can argue
> > > that
> > > we should register *later* when the firmware is loaded. But this
> > > is
> > > really not helping all that much because the firmware can also be
> > > stopped at any time. So you'd want us to register / unregister
> > > the
> > > thermal zone anytime the firmware is loaded / unloaded?
> >=20
> > You might have to do that.=C2=A0=C2=A0I think that if the firmware =
enables a
> > feature then
> > the act of loading the firmware should run the code that enables
> > the feature.
> > IMO of course.
>=20
> But I suspect that the iwlwifi firmware is loaded during interface up
> (and unloaded during interface down) and in that case
> register/unregister would be happening all the time. That doesn't
> sound
> like a good idea. I would rather try to fix the thermal interface to
> handle the cases when the measurement is not available.

I totally agree with Emmanuel and Kalle. =C2=A0We should not change thi=
s.
=C2=A0It is a design decision to return an error when the interface is =
down,
this is very common with other subsystems as well. =C2=A0The userspace
should be able to handle errors and report something like "unavailable"
when this kind of error is returned.

I'm not sure EIO is the best we can have, but for me that's exactly
what it is. =C2=A0The thermal zone *is* there, but cannot be accessed
because the firmware is not available. =C2=A0I'm okay to change it to E=
BUSY,
if that would help userspace, but I think that's a bit misleading. =C2=A0=
The
device is not busy, on the contrary, it's not even running at all.

=46urthermore, I don't think this is "breaking userspace" in the sense =
of
being a regression. =C2=A0The userspace API has always been implemented=
 with
the possibility of returning errors. =C2=A0It's not a good design if a
single device returning an error causes all the other devices to also
fail.

--
Cheers,
Luca.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
