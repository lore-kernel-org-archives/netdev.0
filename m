From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: Possible double-free in the usbnet driver
Date: Sat, 05 Mar 2016 20:53:07 +0100
Message-ID: <DBDB517D-E4A4-4422-AECE-52194FE2AED0@mork.no>
References: <CA+55aFxqwjs5gs6Fw2jmTteWM4hZTnr7Ls111ExNTieObLs82Q@mail.gmail.com> <CA+fCnZfS51F7WZEM1YTSPDMWSzvBTJWGf5cRWv5LrNCSOf_-qA@mail.gmail.com> <CA+55aFwxbs_hLG58Q_xSK2vpufjmwMk-xkqxTNh_5h-A8y4vbg@mail.gmail.com> <1457193090.8935.7.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrey Konovalov <andreyknvl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457193090.8935.7.camel-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On March 5, 2016 4:51:30 PM CET, Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org> wrote=
:
>On Fri, 2016-03-04 at 14:43 -0800, Linus Torvalds wrote:
>
>> So you have usbnet_defer_kevent() getting triggered, which in turn
>> ends up using "usbnet->kevent"
>>=20
>> But somebody like Oliver is really the right person to check this.
>For
>> example, it's entirely possible that we should just instead do
>>=20
>>         cancel_work_sync(&dev->kevent);
>>=20
>> before the "free_netdev(net)" in the "out1" label.
>
>Hi Bjorn,
>
>I thinbk Linus has analyzed this correctly, but the fix really needs
>to cancel the work, because we can also fail later after bind() has
>already run. However, still cdc-ncm and the other drivers should clean
>up after themselves if bind() fails, as usbnet really cannot known wha=
t
>the subdrivers have done.
>
>So in conclusion, I think Linus' fix should also go into cdc-ncm.

Definitely.  The patch is so obviously correct that we can only wonder =
how it was possible to miss it it the first place :)

Will take a look to see if we could do a better job cleaning up in othe=
r places.

(I do also wonder a bit about the failure to bind - is that expected or=
 is there some bug in the cdc_ncm descriptor parsing?)


Bj=C3=B8rn

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
