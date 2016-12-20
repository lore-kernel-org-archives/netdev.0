From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Tue, 20 Dec 2016 13:47:23 +0200
Message-ID: <87shpiu8j8.fsf@kamboji.qca.qualcomm.com>
References: <201611111820.52072@pali> <201612181204.52928@pali>
        <83b2e9a4-f990-68a8-241e-375e46448d47@broadcom.com>
        <201612181309.01298@pali>
        <fd180271-1cd4-9891-e3d5-ae9cd0fb088b@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>,
        Daniel Wagner <wagi@monom.org>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Tom Gundersen <teg@jklm.no>,
        Johannes Berg <johannes@sipsolutions.net>,
        Ming Lei <ming.lei@canonical.com>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        =?utf-8?Q?Rafa=C5=82_Mi=C5=82eck?= =?utf-8?Q?i?=
        <zajec5@gmail.com>, Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.ke
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fd180271-1cd4-9891-e3d5-ae9cd0fb088b@broadcom.com> (Arend Van
        Spriel's message of "Sun, 18 Dec 2016 21:08:43 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arend Van Spriel <arend.vanspriel@broadcom.com> writes:

> On 18-12-2016 13:09, Pali Roh=C3=A1r wrote:
>
>> File wl1251-nvs.bin is provided by linux-firmware package and contains=20
>> default data which should be overriden by model specific calibrated=20
>> data.
>
> Ah. Someone thought it was a good idea to provide the "one ring to rule
> them all". Nice.

Yes, that was a bad idea. wl1251-nvs.bin in linux-firmware.git should be
renamed to wl1251-nvs.bin.example, or something like that, as it should
be only installed to a real system only if there's no real calibration
data available (only for developers to use, not real users).

>> But overwriting that one file is not possible as it next update of=20
>> linux-firmware package will overwrite it back. It break any normal usage=
=20
>> of package management.
>>=20
>> Also it is ridiculously broken by design if some "boot" files needs to=20
>> be overwritten to initialize hardware properly. To not break booting you=
=20
>> need to overwrite that file before first boot. But without booting=20
>> device you cannot read calibration data. So some hack with autoreboot=20
>> after boot is needed.

Providing the calibration data via Device Tree is the proper way to
solve this. Yes yes, I know N900 doesn't support it but that's a
deficiency in N900, not Linux.

>> And how to detect that we have real overwritten calibration data and
>> not default one from linux-firmware? Any heuristic or checks will be
>> broken here. And no, nothing like you need to reboot your device now
>> (and similar concept) from windows world is not accepted.
>
> Well. After reading and creating calibration data you could just rebind
> the driver to the device to have it probed again.

Or load wl1251 as a module and make sure calibration data is installed
before the module is loaded. LEDE does that with ath10k:

https://git.lede-project.org/?p=3Dsource.git;a=3Dblob;f=3Dtarget/linux/ar71=
xx/base-files/etc/hotplug.d/firmware/11-ath10k-caldata;h=3D97875bd79a579a00=
10da3f60324b6ec966fe9c6a;hb=3DHEAD

> But yeah, the default one from linux-firmware should never have been
> there in the first place.

Agreed.

--=20
Kalle Valo
