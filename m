From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: qmi_wwan: fix Oops while disconnecting
Date: Mon, 25 Jun 2012 10:27:13 +0200
Message-ID: <87d34nhk4e.fsf@nemi.mork.no>
References: <1340356279-3124-1-git-send-email-bjorn@mork.no>
	<201206232255.08319.oliver@neukum.org> <877guxhx44.fsf@nemi.mork.no>
	<201206241413.08339.oliver@neukum.org>
	<0e34226c-8fe7-4e2e-8fc2-2ed140f23e9b@email.android.com>
	<CACVXFVN3wJ3NWxSGj-yWCgtDE_sgJT5CZYHwYUWk1MxkphcsTg@mail.gmail.com>
	<87hatzhn0k.fsf@nemi.mork.no>
	<CACVXFVOPjFSS6Sv6AUCSAs4nywR045QhjYAbN8g6U3adsUbujw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Marius =?utf-8?Q?Bj=C3=B8rnstad?= Kotsbak
	<marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVOPjFSS6Sv6AUCSAs4nywR045QhjYAbN8g6U3adsUbujw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ming Lei's message of "Mon, 25 Jun 2012 16:08:52 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> On Mon, Jun 25, 2012 at 3:24 PM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrot=
e:
>
>> There is no problem wrt qmi_wwan and intfdata as long as the NULL te=
st
>> is added to .manage_power.
>
> It depends on the ARCH or compiler.
>
> Considered there is not any locking/memory barrier between the set to=
 NULL
> and read the pointer, also no ACCESS_ONCE on read or store the pointe=
r,
> reading in .manage_power may see a invalid pointer if the CPU doesn't
> support Store Atomicity or the compiler does a byte-at-a-time optimiz=
ation
> on the store[1].
>
> So why not take the correct way in theory? also it is a general solut=
ion,
> and we can document its usage.
>
>
> [1], Paul mentioned it in the previous discussion
> http://lkml.org/lkml/2012/6/6/280

I don't believe that is valid for pointers, which hopefully either have
native word size or are protected by the compiler.

In any case, I'm not prepared to deal with the situation that changing =
a
pointer from valid to NULL can cause intermediate invalid pointers.  If
such an architecture/compiler exists, then I believe the sanest thing t=
o
do is to let it fail randomly.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
