From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 5/6] wl1251: Parse and use MAC address from supplied NVS data
Date: Fri, 27 Jan 2017 09:54:34 +0200
Message-ID: <87poj9ndj9.fsf@codeaurora.org>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
        <1482598381-16513-6-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482598381-16513-6-git-send-email-pali.rohar@gmail.com> ("Pali
        \=\?utf-8\?Q\?Roh\=C3\=A1r\=22's\?\= message of "Sat, 24 Dec 2016 17:53:00 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

> This patch implements parsing MAC address from NVS data which are sent to
> wl1251 chip. Calibration NVS data could contain valid MAC address and it
> will be used instead randomly generated.
>
> This patch also move code for requesting NVS data from userspace to driver
> initialization code to make sure that NVS data will be there at time when
> permanent MAC address is needed.
>
> Calibration NVS data for wl1251 are model specific. Every one device with
> wl1251 chip should have been calibrated in factory and needs to provide o=
wn
> calibration data.
>
> Default example wl1251-nvs.bin data found in linux-firmware repository and
> contains MAC address 00:00:20:07:03:09. So this MAC address is marked as
> invalid as it is not real device specific address, just example one.
>
> Format of calibration NVS data can be found at:
> http://notaz.gp2x.de/misc/pnd/wl1251/nvs_map.txt
>
> Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>

[...]

> +static int wl1251_read_nvs_mac(struct wl1251 *wl)
> +{
> +	u8 mac[ETH_ALEN];
> +	int i;
> +
> +	if (wl->nvs_len < 0x24)
> +		return -ENODATA;
> +
> +	/* length is 2 and data address is 0x546c (mask is 0xfffe) */
> +	if (wl->nvs[0x19] !=3D 2 || wl->nvs[0x1a] !=3D 0x6d || wl->nvs[0x1b] !=
=3D 0x54)
> +		return -EINVAL;
> +
> +	/* MAC is stored in reverse order */
> +	for (i =3D 0; i < ETH_ALEN; i++)
> +		mac[i] =3D wl->nvs[0x1c + ETH_ALEN - i - 1];

No magic numbers, please. Replace all nvs offsets with proper defines to
make the code more readable.

--=20
Kalle Valo
