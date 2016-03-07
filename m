From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Possible double-free in the usbnet driver
Date: Mon, 07 Mar 2016 14:54:06 -0500 (EST)
Message-ID: <20160307.145406.188091362181073486.davem@davemloft.net>
References: <CA+55aFw43uKkUK-h=VMwXcb9NM+g2AdeB960kWb4YihmjQ8DRw@mail.gmail.com>
	<20160307.141100.1511700720120062677.davem@davemloft.net>
	<CA+fCnZdurxGBsOrANb_m5BLK1BKzH3J_GmZ=dbH=ABThgFNGxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org, oneukum-IBi9RG/b67k@public.gmane.org,
	dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+fCnZdurxGBsOrANb_m5BLK1BKzH3J_GmZ=dbH=ABThgFNGxg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 7 Mar 2016 22:50:41 +0300

> On Mon, Mar 7, 2016 at 10:11 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> w=
rote:
>> From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
>> Date: Mon, 7 Mar 2016 10:13:09 -0800
>>
>>> On Sat, Mar 5, 2016 at 11:53 AM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote=
:
>>>>
>>>>
>>>> Definitely.  The patch is so obviously correct that we can only wo=
nder how it was possible to miss it it the first place :)
>>>>
>>>> Will take a look to see if we could do a better job cleaning up in=
 other places.
>>>
>>> What should I do for 4.5? Will there be a pull request for this, or
>>> should I just commit my cdc_ncm_bind() patch directly?
>>
>> Yes I plan to send you a pull request today with Oliver's fix.
>>
>> Assuming this is what you guys are referring to:
>>
>> commit 1666984c8625b3db19a9abc298931d35ab7bc64b
>> Author: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
>> Date:   Mon Mar 7 11:31:10 2016 +0100
>>
>>     usbnet: cleanup after bind() in probe()
>>
>>     In case bind() works, but a later error forces bailing
>>     in probe() in error cases work and a timer may be scheduled.
>>     They must be killed. This fixes an error case related to
>>     the double free reported in
>>     http://www.spinics.net/lists/netdev/msg367669.html
>>     and needs to go on top of Linus' fix to cdc-ncm.
>>
>>     Signed-off-by: Oliver Neukum <ONeukum-IBi9RG/b67k@public.gmane.org>
>>     Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>=20
> Could you also add:
> Reported-by: Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ?

Sorry it's already committed to my tree and I can't redo the commit mes=
sage
once that happens since my tree has static history.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
