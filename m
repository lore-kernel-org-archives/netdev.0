From: Michal Kazior <michal.kazior@tieto.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Tue, 22 Nov 2016 16:22:57 +0100
Message-ID: <CA+BoTQm5yZYccMherMnmxZ0_b2PqkCWf_0nBoRLzsro-Ujz1eQ@mail.gmail.com>
References: <201611111820.52072@pali> <20161121155153.GM13735@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Kalle Valo <kvalo@codeaurora.org>, Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161121155153.GM13735@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21 November 2016 at 16:51, Pali Roh=C3=A1r <pali.rohar@gmail.com> wrote:
> On Friday 11 November 2016 18:20:50 Pali Roh=C3=A1r wrote:
>> Hi! I will open discussion about mac address and calibration data for
>> wl1251 wireless chip again...
>>
>> Problem: Mac address & calibration data for wl1251 chip on Nokia N900
>> are stored on second nand partition (mtd1) in special proprietary format
>> which is used only for Nokia N900 (probably on N8x0 and N9 too).
>> Wireless driver wl1251.ko cannot work without mac address and
>> calibration data.

Same problem applies to some ath9k/ath10k supported routers. Some even
carry mac address as implicit offset from ethernet mac address. As far
as I understand OpenWRT cooks cal blobs on first boot prior to loading
modules.


>> Absence of mac address cause that driver generates random mac address at
>> every kernel boot which has couple of problems (unstable identifier of
>> wireless device due to udev permanent storage rules; unpredictable
>> behaviour for dhcp mac address assignment, mac address filtering, ...).
>>
>> Currently there is no way to set (permanent) mac address for network
>> interface from userspace. And it does not make sense to implement in
>> linux kernel large parser for proprietary format of second nand
>> partition where is mac address stored only for one device -- Nokia N900.
>>
>> Driver wl1251.ko loads calibration data via request_firmware() for file
>> wl1251-nvs.bin. There are some "example" calibration file in linux-
>> firmware repository, but it is not suitable for normal usage as real
>> calibration data are per-device specific.

You could hook up a script that cooks up the cal/mac file via
modprobe's install hook, no?


Micha=C5=82
