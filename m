From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] usbnet: fix status interrupt urb handling
Date: Wed, 13 Nov 2013 10:15:46 +0100
Message-ID: <1384334146.5724.13.camel@linux-fkkt.site>
References: <1384270481-30972-1-git-send-email-nbd@openwrt.org>
	 <1384329672.5724.6.camel@linux-fkkt.site> <87r4akoefv.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87r4akoefv.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-11-13 at 10:09 +0100, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:
>=20
> > On Tue, 2013-11-12 at 16:34 +0100, Felix Fietkau wrote:
> >> Since commit 7b0c5f21f348a66de495868b8df0284e8dfd6bbf
> >> "sierra_net: keep status interrupt URB active", sierra_net trigger=
s
> >> status interrupt polling before the net_device is opened (in order=
 to
> >> properly receive the sync message response).
> >>=20
> >> To be able to receive further interrupts, the interrupt urb needs =
to be
> >> re-submitted, so this patch removes the bogus check for netif_runn=
ing().
> >
> > And what about the other drivers for whom this patch means added
> > traffic? This fix is done with a sledge hammer and cares only about
> > some drivers.
>=20
> usbnet_stop calls usbnet_status_stop which kills the status URB, unle=
ss
> the driver explicitly asked for it not to be killed.  And the callbac=
k
> properly returns on status =3D=3D -ENOENT, before the lines in questi=
on.
>=20
> So I think Felix is right.   None of the other drivers will ever hit =
the
> code he deletes. It only affects sierra_net, and that is unwanted.

True. I take back the objection.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
