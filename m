From: Florian Klink <flokli@flokli.de>
Subject: Re: cdc-wdm: unable to connect after suspend
Date: Wed, 11 Jun 2014 12:08:39 +0200
Message-ID: <53982AA7.3090508@flokli.de>
References: <ln6m4k$q49$1@ger.gmane.org> <874mzt55kz.fsf@nemi.mork.no>	<53971171.5070001@flokli.de> <539712BA.5010004@flokli.de> <87lht350y0.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="h1fKSL3AnBfuB4U3bLwkD4VRDeOMecqO3"
Cc: netdev@vger.kernel.org, modemmanager-devel@lists.freedesktop.org
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asterix.flokli.de ([78.46.104.9]:52580 "EHLO asterix.flokli.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757AbaFKKIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 06:08:42 -0400
In-Reply-To: <87lht350y0.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--h1fKSL3AnBfuB4U3bLwkD4VRDeOMecqO3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 11.06.2014 10:01, schrieb Bj=C3=B8rn Mork:
> Florian Klink <flokli@flokli.de> writes:
>> Am 10.06.2014 16:08, schrieb Florian Klink:
>>> Am 10.06.2014 14:09, schrieb Bj=C3=83=C5=BErn Mork:
>>>> Florian Klink <flokli@flokli.de> writes:
>>>>
>>>>> Hi,
>>>>>
>>>>> I recently bought a notebook (Fujitsu Lifebook T904) with integrate=
d
>>>>> 3G/4G modem (Sierra Wireless EM7305) thats powered by the cdc-wdm d=
river.
>>>>>
>>>>> It works without any problems on a fresh bootup using Networkmanage=
r.
>>>>>
>>>>> However, after putting the notebook into standby and waking up agai=
n,
>>>>> I'm unable to get a connection (always reproducible, not signal qua=
lity
>>>>> related).
>>>>
>>>> Does it work again if you restart NetworkManager and ModemManager at=

>>>> this point?
>>>
>>> Nope. ModemManager gets confused completely and drops the modem out o=
f
>>> the list of connections:
>>>
>>> ModemManager[3067]: <warn>  Couldn't find support for device at
>>> '/sys/devices/pci0000:00/0000:00:19.0': not supported by any plugin
>>> ModemManager[3067]: <warn>  Couldn't find support for device at
>>> '/sys/devices/pci0000:00/0000:00:1c.3/0000:03:00.0': not supported by=

>>> any plugin
>>> ModemManager[3067]: [/dev/cdc-wdm1] Queried max control message size:=
 4096
>>> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in receive=
d
>>> message
>=20
> Ah, OK.  Then I obviously guessed wrong.  MM and the firmware does not
> agree on the current transaction sequence. I'm not sure why. The modem
> is sending unexpected messages, and I assume MM doesn't get the answers=

> it is looking for.  This could be caused by the driver cancelling the
> interrupt URB at an "inconvenient time" for the firmware.  But I haven'=
t
> seen issues like that with the Qualcomm based Sierra modems before.
>=20
> And you get into this state consistently on every suspend+resume?=20
>=20
> It would be useful to know which unexpeced messages we receive (errors?=

> same message all over? older queued up messages being played back with
> unexpected delay?)  Any chance you can enable libmbim + ModemManager
> debugging to get the MBIM message dumps?

Sure, I can provide the message dumps. Is it as simple as described in
here (http://www.freedesktop.org/wiki/Software/ModemManager/Debugging/),
or do I need to recompile libmbim + ModemManager with some additional (de=
bug)
flags enabled?

>=20
>=20
>>>> Does it help to do
>>>>
>>>>  echo  0 >/sys/bus/usb/devices/x-y/power/persist
>>>>
>>>> prior to suspending the notebook?  You'll have to replace "x-y" with=
 the
>>>> correct USB bus and port number.  You can find this in e.g. the dmes=
g
>>>> output.  For example, if your log shows:
>>>>
>>>>   qmi_wwan 2-4:1.8: cdc-wdm0: USB WDM device
>>>>
>>>> then x-y =3D 2-4.
>>>
>>> dmesg shows "cdc_mbim 1-6:2.12: cdc-wdm1: USB WDM device", so I did e=
cho
>>> 0 > /sys/bus/usb/devices/1-6/power/persist.
>>>
>>> However, after a suspend/resume cycle, connecting didnt work either.
>>> Errors were the same as without persist =3D 0.
>=20
> Yes, my initial guess was wrong, so this is not the problem.
>=20
>>> dmesg doesn't really show an error message from the modem. Seems like=
 it
>>> also has an issue resuming "Bus 001 Device 006: ID 0483:91d1
>>> STMicroelectronics", but this shouldn't cause the problems with the m=
odem...
>>
>> I attached the dmesg output, probably there's till something interesti=
ng
>> inside ;-)
>=20
> Thanks.  I wasn't expecting any errors there (I still don't think there=

> is any real error here from the drivers point of view), but I wanted to=

> see whether the modem is disconnected and rediscovered or just plainly
> suspended.
>=20
> But???  I cannot find anything related to the modem device in that log?=

> Not even anything mentioning the "1-6" USB port.

I just sent the part of dmesg where the suspend & resume cycle happened.

Of course, I see the device appearing on bootup:

[   11.537522] usb 1-6: new high-speed USB device number 11 using xhci_hc=
d
[   11.711214] usb 1-6: config 1 has an invalid interface number: 8 but m=
ax is 3
[   11.711217] usb 1-6: config 1 has no interface number 1
[   11.711432] usb 1-6: config 2 has an invalid interface number: 12 but =
max is 1
[   11.711434] usb 1-6: config 2 has an invalid interface number: 13 but =
max is 1
[   11.711435] usb 1-6: config 2 has an invalid interface number: 13 but =
max is 1
[   11.711437] usb 1-6: config 2 has no interface number 0
[   11.711439] usb 1-6: config 2 has no interface number 1

[...]

[   14.735330] usbcore: registered new interface driver cdc_ncm
[   14.736046] usbcore: registered new interface driver cdc_wdm
[   14.738273] cdc_mbim 1-6:2.12: cdc-wdm1: USB WDM device
[   14.738459] cdc_mbim 1-6:2.12 wwan0: register 'cdc_mbim' at usb-0000:0=
0:14.0-6, CDC MBIM, 96:ba:xx:xx:xx:xx
[   14.738477] usbcore: registered new interface driver cdc_mbim
[   14.749795] systemd-udevd[248]: renamed network interface wwan0 to wwp=
0s20u6c2i12

=2E.. but you don't get any dmesg output about it during the suspend/resu=
me cycle.

Florian


--h1fKSL3AnBfuB4U3bLwkD4VRDeOMecqO3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJTmCqnAAoJEInyWbj6DRgfqTEQAK/2juYTwbjhFpbvsiTiqwlc
44HuZIQw6GUIDpsDb8+zjiDofPmlgSayfg34MAa362UEXowkGGLcSDrR5u4uAlIF
FCeB8XZrebSv7zgmWsp+SsYEpqIaDRzEIwbksaFZaBOL7YLHtf3azb7fTJZIQZrO
4oeHDUx4mCaoii9NFqkOyfM1yjn9LUI76Ncaf95uR3vbCZeGRfD89L6W3HuvcDFF
92U5V7vf+fjLQAi4h7BCThUO9VqYwBrGXFsigm6DRbEfUY2bbV/RrAiP3WOuPDiC
K7Zl0bYXd51kRHuwpqXIZHkGBYokjnAkqRCr1KGJ2cjGIjec+khB45+9W4sytKSk
4hxeGz9cFzM2cUIyKz7PFm99qYmO3SjmKakWbb0ClHwRwyzCT2i6BA5hbt6BzYwg
oOp4Rg7emqqfktqLH6zqgrvm4p9ExnSc+UgJd7I4C+JWzhjTC+rSiqy22r0iNY8F
4ZkU6KfuORX0y4/jKzcBuEcXt0a0ukiniDazKtG1V0Kjx8MW1QDhiLUkV1tNbaPF
L7VAsvO33exrGM9aw2CIHYJbkeJkeorK7z3cnFUNmBbmQwUUYQEio+SiArJHCHXT
fdjwY+p9G/JgnnBVSi7aDJaYxyhlS2SrbKNs9WezdxonmYx+1WRqS3/qjZiWDguX
vmcqKviLzVR/IxZJ0X35
=bL0C
-----END PGP SIGNATURE-----

--h1fKSL3AnBfuB4U3bLwkD4VRDeOMecqO3--
