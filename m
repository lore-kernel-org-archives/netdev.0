From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Thu, 28 Jun 2012 10:40:55 +0200
Message-ID: <201206281040.55402.oliver@neukum.org>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no> <87lij7de8u.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marius =?utf-8?q?Bj=C3=B8rnstad_Kotsbak?=
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?utf-8?q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87lij7de8u.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Donnerstag, 28. Juni 2012, 10:36:49 schrieb Bj=C3=B8rn Mork:
> Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> writes:
>=20
> [..]
> > Fixes this Oops where a cdc-wdm device was closed while the
> > USB device was disconnecting, causing wdm_release to call
> > qmi_wwan_cdc_wdm_manage_power after intfdata was set to
> > NULL by usbnet_disconnect:
> >
> > [41819.087460] BUG: unable to handle kernel NULL pointer dereferenc=
e at 00000080
> > [41819.087815] IP: [<f8640458>] qmi_wwan_manage_power+0x68/0x90 [qm=
i_wwan]
> > [41819.088028] *pdpt =3D 000000000314f001 *pde =3D 0000000000000000
> > [41819.088028] Oops: 0002 [#1] SMP
>=20
> [..]
>=20
> > diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.=
c
> > index 3767a12..b01960f 100644
> > --- a/drivers/net/usb/qmi_wwan.c
> > +++ b/drivers/net/usb/qmi_wwan.c
> > @@ -197,6 +197,10 @@ err:
> >  static int qmi_wwan_cdc_wdm_manage_power(struct usb_interface *int=
f, int on)
> >  {
> >  	struct usbnet *dev =3D usb_get_intfdata(intf);
> > +
> > +	/* can be called while disconnecting */
> > +	if (!dev)
> > +		return 0;
> >  	return qmi_wwan_manage_power(dev, on);
> >  }
>=20
> Hello,
>=20
> I'd like this patch applied to qmi_wwan regardless of the outcome of =
the
> (now stalled?) generic usbnet_disconnect discussion.
>=20
> The patch fixes a real Oops in 3.4 and 3.5, and I believe it should b=
e
> left in qmi_wwan even if the usbnet code is fixed to avoid this speci=
fic
> bug.  The additional NULL test won't harm, and it makes the code more
> robust should someone decide to rearrange usbnet_disconnect again at
> some later point in time.
>=20
> I really want this fixed in the next 3.4 stable release, if possible.
> Should I resubmit the patch, or will you pick it up from
> http://patchwork.ozlabs.org/patch/166542/ ?

Yes.

David, can you please apply this? It needs to also go into stable.
We might remove this in later releases, but for now it is needed.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
