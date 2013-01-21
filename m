From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Mon, 21 Jan 2013 09:31:32 +0100
Message-ID: <87sj5vszrv.fsf@nemi.mork.no>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
	<22276933.xSGyXJfOvq@linux-5eaq.site> <871udiur74.fsf@nemi.mork.no>
	<CAL_Kpj1B=_+eN3Y0n3d9_r4JoeHD2LQFSU+b+taCZL0G4icu6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_Kpj1B=_+eN3Y0n3d9_r4JoeHD2LQFSU+b+taCZL0G4icu6A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Alexey Orishko's message of "Sun, 20 Jan 2013 01:21:20 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> On Fri, Jan 18, 2013 at 10:17 PM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wro=
te:
>
>>>> Some Sierra Wireless firmwares support CDC MBIM but have no CDC
>>>> Union funtional descriptor. This violates the MBIM specification,
>
> I don't believe Sierra Wireless violates MBIM specification.
> See in the specification: "there are two ways to group interfaces: th=
e
> WHCM Union functional descriptor and IAD."

I disagree.  This is not about the WHCM Union descriptor, it's about th=
e
CDC Union descriptor.  WHCM is of course not mandatory.

Quoting that whole section from the MBIM specification:

<quote>
  6.1 OVERVIEW
 =20
  A USB MBIM function is implemented as a USB CDC function with two
  interfaces.  Functions shall provide a CDC Union functional descripto=
r
  to group these two interfaces.  See [USBWMC11].
 =20
  A Communication Class interface, with class 02h and subclass 0Eh, and
  a Data Class interface combine to form a single functional unit
  representing the USB MBIM device.  The Communication Class interface
  includes a single endpoint for event notification; it also uses the
  device=E2=80=99s default pipe for control messages.  The Data Class i=
nterface
  includes two bulk endpoints for data traffic.
 =20
  There are two ways to group interfaces: the WHCM Union Functional
  Descriptor (see [USBWMC11]) and the IAD.  Devices may also provide an
  IAD.  If an IAD is provided, the information in the IAD for MBIM
  functions shall be consistent with the information in the CDC Union
  descriptor and Communication Class interface descriptor.
</quote>


The "Functions shall provide a CDC Union functional descriptor to group
these two interfaces." is pretty clear IMHO.  You also have table 6=E2=80=
=902
listing the HEADER, UNION and MBIM functional descriptors as "Required"=
=2E

There is absolutely not way to make this anything but a firmware bug.

But I am all for working around it, of course.  There also seems to be =
a
couple more oddities with the MBIM mode of this device compared to the
other I've seen, but those are more likely revealing driver bugs.  I
intend to fix them as well.



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
