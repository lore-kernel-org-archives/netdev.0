From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 1/2 v4] usbnet: allow status interrupt URB to always be active
Date: Wed, 10 Apr 2013 15:25:49 +0200
Message-ID: <87li8q5xgi.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1357318096.5370.15.camel@dcbw.foobar.com>
	<1364488207.1877.20.camel@dcbw.foobar.com>
	<CACVXFVMBAzTYZKiE_uSTqr_yB4f7c5_PSnK=LBP6=oWdWwYHfg@mail.gmail.com>
	<1364832288.3059.12.camel@dcbw.foobar.com>
	<1365548547.23372.2.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	Phil Sutter <phil-ydcDiazATMQ@public.gmane.org>
To: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1365548547.23372.2.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org> (Dan Williams's
	message of "Tue, 09 Apr 2013 18:02:27 -0500")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> +int usbnet_status_start(struct usbnet *dev, gfp_t mem_flags)
> +{
> +	/* Only drivers that implement a status hook should call this */
> +	BUG_ON(dev->interrupt =3D=3D NULL);
>=20
I still don't think there is any reason to BUG out. See for example
http://article.gmane.org/gmane.linux.kernel/52102

> +static void __usbnet_status_stop(struct usbnet *dev, bool force)
> +{
> +	if (dev->interrupt) {
> +		mutex_lock(&dev->interrupt_mutex);
> +		if (!force)
> +			BUG_ON(dev->interrupt_count =3D=3D 0);

Same here.  You can deal with this just fine.  Warn once, and go on
ignoring the problem.  Why kill the machine because of some minor drive=
r
issue?



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
