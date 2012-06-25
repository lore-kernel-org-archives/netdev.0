From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Mon, 25 Jun 2012 09:24:43 +0200
Message-ID: <87hatzhn0k.fsf@nemi.mork.no>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<201206232255.08319.oliver@neukum.org> <877guxhx44.fsf@nemi.mork.no>
	<201206241413.08339.oliver@neukum.org>
	<0e34226c-8fe7-4e2e-8fc2-2ed140f23e9b@email.android.com>
	<CACVXFVN3wJ3NWxSGj-yWCgtDE_sgJT5CZYHwYUWk1MxkphcsTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marius =?utf-8?Q?Bj=C3=B8rnstad?= Kotsbak
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVN3wJ3NWxSGj-yWCgtDE_sgJT5CZYHwYUWk1MxkphcsTg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ming Lei's message of "Mon, 25 Jun 2012 11:37:20 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[I don't have anything more to add to the generic usbnet discussion, bu=
t
 want to comment on the qmi_wwan issues]

Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> Also, the clear of intfdata may not be observed in .manage_power
> since usb_set_intfdata(, NULL) may be completed after the lock wdm_mu=
tex
> operation.

True, but irrelevant.  The pointer is either valid or NULL.  We don't
need to care about synchronizing the exact time it is set to NULL.

The locking in cdc-wdm will ensure that the pointer is valid while it i=
s
in use by .manage_power, because usbnet_disconnect is prevented from
continuing with free_netdev() while any caller of .manage_power is
running.

> So it is only the sync mechanism that  works on the race even the che=
ck is
> added in the patch.  Putting usb_set_intfdata(, NULL) after driver_in=
fo->unbind
> should be OK, and it is a general solution for the problem.

There is no problem wrt qmi_wwan and intfdata as long as the NULL test
is added to .manage_power.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
