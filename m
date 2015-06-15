From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net:usb:cdc_ncm: fix that tag Huawei devices as wwan
Date: Mon, 15 Jun 2015 12:22:27 +0200
Message-ID: <30508675-5839-4E65-975A-4CFC5B1C5E24@holtmann.org>
References: <SNT147-W99A0E937260823EBAA1FFB3B90@phx.gbl> <CA+55aFz3S3nR_aDMMS1vcayyEqJCBL5tgoYAfDE2WGyM3Vcrww@mail.gmail.com> <87ioapl55s.fsf@nemi.mork.no>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Aleksander Morgado <aleksander@aleksander.es>,
	Dan Williams <dcbw@redhat.com>,
	Oliver Neukum <oliver@neukum.org>,
	Ben Hutchings <ben.hutchings@codethink.co.uk>,
	USB list <linux-usb@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	xiaomao <xiaomao0213@hotmail.com>
To: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33656 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425AbbFOKWc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 06:22:32 -0400
In-Reply-To: <87ioapl55s.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bjorn,

>> Hmm. Oliver is marked as the maintainer of the USB CDC code, but
>> others have touched it more recently. So I'm just wildly adding peop=
le
>> to the cc to comment on this patch and maybe apply it.
>> Oliver/David/Ben/Bj=C3=B8rn?
>=20
> Adding Aleksander and Dan, too.  The 'wwanX' vs 'usbX' distinction is=
 a
> hint for userspace and nothing more. We try our best to make this hin=
t
> as precise as possible, but there has never been any guarantee that i=
t
> is 100% correct.  So userspace will have to deal with hints being wro=
ng.
> This has been discussed before:
> http://lists.freedesktop.org/archives/modemmanager-devel/2014-April/0=
01068.html
>=20
> What makes the Huawei NCM devices special is that the same ID is reus=
ed
> for both types of devices, making it impossible to achieve perfect
> hinting by adding exceptions to the generic rule.  We can choose betw=
een
> wrong towards 'wwanX' or wrong towards 'usbX'.  But the hint WILL be
> wrong in some cases no matter what we do.
>=20
> The 12d1:1506 device ID is a perfect example.  Here's a report of a
> Huawei E5776 which should be used as a plain 'usbX' NCM device:
> http://lists.freedesktop.org/archives/modemmanager-devel/2014-April/0=
01040.html
> And here's a report of a Huawei E3276 which needs wwan management and
> therefore should be hinted as a 'wwanX' NCM device:
> http://www.dd-wrt.com/phpBB2/viewtopic.php?p=3D764920
>=20
> So which of the two wrongs should we choose?
>=20
> Huawei wanting this changed is a strong argument for the 'usbX'
> direction, of course.  But this will be a user visible change which i=
s
> likely to break currently working devices until userspace adapts.  An=
d
> that will normally trump almost any other argument.  I don't think we
> can change this now.  I sincerely apologise about having added the
> generic rule in the first place, but I don't see how I can go back an=
d
> change that.
>=20
> I believe we have to follow the path of least surprise: Keeping what =
we
> have.
>=20
> But we should definitely work with userspace to ensure that a wrongly
> flagged 'wwanX' device is usable without any wwan management.
> Preferably without the user really noticing anything different (excep=
t
> possibly the device name).

we introduced DEVTYPE in uevent a long time ago. That is what userspace=
 should be using and not second guessing on interface names.

Why is userspace trying to hack around the kernel anyway. This never re=
ally goes well unless the kernel exposes clear information to identify =
devices. If there are some weird devices, then work this out in the ker=
nel and have DEVTYPE identity them correctly.

Regards

Marcel
