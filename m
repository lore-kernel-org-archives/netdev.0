From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH 4/7] usbnet: cdc_mbim: don't recover device if suspend
 fails in system sleep
Date: Tue, 5 Mar 2013 11:54:21 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.1303051147300.1308-100000@iolanthe.rowland.org>
References: <87wqtlommw.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87wqtlommw.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 5 Mar 2013, Bj=C3=B8rn Mork wrote:

> Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
>=20
> > Yes, USB core will flush any outstanding URBs, but the driver still=
 need
> > to deal with suspend failure carefully, for example, suppose usb_re=
sume()
> > is called in suspend failure path, and the submitted URBs are kille=
d
> > by USB core later. But after the device is wakeup, and the resume()=
 will
> > do nothing since the suspend count is leaked. So it is what the pat=
ches
> > are fixing, and it is better to not depend on the default flushing =
URBs of
> > USB core.
>=20
> I am starting to wonder why the USB core has combined system suspend =
and
> runtime suspend if we are going to end up with every driver testing
> PMSG_IS_AUTO(message) and selecting a completely different code path.

Mainly for historical reasons.  System suspend existed long before=20
runtime suspend did.  When runtime suspend was added, it piggybacked=20
off the existing code.  Furthermore, originally there was no=20
requirement that system suspend always succeed; that was added later.

Also, the code paths are not completely different.  They differ mainly=20
in their error handling.  But when you think about it, how serious an=20
error can you encounter when you try to _stop_ using a device?

> You are right that we will end up with problems if usbnet_resume is
> called for a device usbnet hasn't suspended.  But I'd still claim tha=
t
> is a bug in the USB core, which is the one that decided to ignore the
> suspend error and still call resume.
>=20
> I guess proper error handling here require the USB core to see the
> interface driver as dead if it fails to suspend on system suspend, an=
d
> do forced rebinding on resume.

You are welcome to submit a patch to do this.  It shouldn't be hard; we
already have a flag indicating that an interface needs to be unbound at
reprobed at resume time.  You can update the kerneldoc in addition; as
you noticed, it currently does not describe the actual code completely
accurately.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
