From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Fri, 27 Jan 2017 14:16:37 +0100
Message-ID: <20170127131637.GJ24223@pali>
References: <87tw8lnei3.fsf@codeaurora.org>
 <20170127094342.GC24223@pali>
 <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
 <20170127101043.GD24223@pali>
 <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
 <20170127103408.GG24223@pali>
 <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
 <20170127115706.GH24223@pali>
 <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
 <bc26f6a5-2865-356f-7f19-f3a316257759@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Ming Lei <ming.lei@canonical.com>,
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
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <bc26f6a5-2865-356f-7f19-f3a316257759@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 27 January 2017 13:53:28 Arend Van Spriel wrote:
> On 27-1-2017 13:26, Kalle Valo wrote:
> > Pali Rohár <pali.rohar@gmail.com> writes:
> > 
> >> On Friday 27 January 2017 13:49:03 Kalle Valo wrote:
> >>> Pali Rohár <pali.rohar@gmail.com> writes:
> >>>
> >>>>> So
> >>>>> for those other platforms there will be a delay waiting for user-mode
> >>>>> helper to fail, before trying to get nvs file from /lib/firmware.
> >>>>
> >>>> Yes, there will be. But there is no easy way to fix this problem that
> >>>> kernel is trying to use default/example NVS data...
> >>>
> >>> Kernel is doing correctly and requesting NVS data as expected, the
> >>> problem here is that linux-firmware claims that the example NVS data is
> >>> real calibration data (which it is not). Distros should not use that,
> >>> only developers for testing purposes. We should not courage users using
> >>> example calibration data.
> >>>
> >>> The simple fix is to rename the NVS file in linux-firmware to something
> >>> like wl1251-nvs.bin.example, no need to workaround this in kernel. If
> >>> you send a patch to linux-firmware I'm happy to ack that.
> >>
> >> I agree with rename and fact that default/example data should not be
> >> used.
> >>
> >> But...
> >>
> >> 1) Kernel should not read device/model specific data from VFS where
> >> are stored not-device-specific files preinstalled by linux
> >> distributions.
> >>
> >> And linux distributions are already putting files into VFS and kernel
> >> cannot enforce userspace to not do that (as they are already doing it).
> > 
> > I'm having problems to understand what you are saying here.
> 
> This is a personal opinion. I read it as: /lib/firmware can only contain
> files for from linux-firmware.
> 
> At least the device-specific vs. non-device-specific does not seem to
> hold. The firmware files that we have in the linux-firmware repository
> are very device-specific. Unless you mean the 'platform' when talking
> about 'device'.

Here I'm talking about files which are specific per unit. Every one N900
has different NVS file (stored in CAL) and so every one N900 device
needs its own NVS file. And we cannot store thousands of NVS files into
linux-firmware repository for each N900 which was ever produced in
factory.

Firmware files in linux-firmware repository are "device" specific, but
"filename" of that file describe exactly for which "device" it is
specific.

But there are thousands of different NVS files for one filename
"wl1251-nvs.bin" and we cannot use one particular for another device. In
linux-firmware is stored "wl1251-nvs.bin" file with example data.

-- 
Pali Rohár
pali.rohar@gmail.com
