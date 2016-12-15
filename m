From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 15 Dec 2016 10:18:44 +0200
Message-ID: <87d1gtli57.fsf@purkki.adurom.net>
References: <201611111820.52072@pali> <201611241749.33681@pali>
        <20161124181138.4i6ehkpohjxfgpbn@earth> <201611241935.32796@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Sebastian Reichel <sre@kernel.org>, Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        "linux-wireless" <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org,
        "Luis R. Rodriguez" <mcgrof@kernel.org>
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201611241935.32796@pali> ("Pali \=\?utf-8\?Q\?Roh\=C3\=A1r\=22's\?\=
 message of "Thu, 24 Nov
        2016 19:35:32 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Adding Luis because he has been working on request_firmware() lately)

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

>> > So no, there is no argument against... request_firmware() in
>> > fallback mode with userspace helper is by design blocking and
>> > waiting for userspace. But waiting for some change in DTS in
>> > kernel is just nonsense.
>>=20
>> I would just mark the wlan device with status =3D "disabled" and
>> enable it in the overlay together with adding the NVS & MAC info.
>
> So if you think that this solution make sense, we can wait what net=20
> wireless maintainers say about it...
>
> For me it looks like that solution can be:
>
> extending request_firmware() to use only userspace helper

I haven't followed the discussion very closely but this is my preference
what drivers should do:

1) First the driver should do try to get the calibration data and mac
   address from the device tree.

2) If they are not in DT the driver should retrieve the calibration data
   with request_firmware(). BUT with an option for user space to
   implement that with a helper script so that the data can be created
   dynamically, which I believe openwrt does with ath10k calibration
   data right now.

> and load mac address also via request_firmware() either by appending it=20
> into NVS data or via separate call

I'm not really fan of the idea providing permanent mac address through
request_firmware(). For example, how to handle multiple devices on the
same host, would there be a need for some kind of bus ids encoded to the
filename? And what about devices with multiple mac addresses?

I wish there would be a better way than request_firmware() to provide
the permanent mac addresses from user space (if device tree is not
available), I just don't know what that could be :) But if we would
start to use request_firmware() for this at least there should be a
wider concensus about that and it should be properly documented, just
like the device tree bindings.

--=20
Kalle Valo
