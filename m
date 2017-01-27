From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Fri, 27 Jan 2017 14:11:46 +0100
Message-ID: <20170127131146.GI24223@pali>
References: <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <87tw8lnei3.fsf@codeaurora.org>
 <20170127094342.GC24223@pali>
 <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
 <20170127101043.GD24223@pali>
 <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
 <20170127103408.GG24223@pali>
 <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
 <20170127115706.GH24223@pali>
 <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>,
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
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 27 January 2017 14:26:22 Kalle Valo wrote:
> Pali Rohár <pali.rohar@gmail.com> writes:
> 
> > On Friday 27 January 2017 13:49:03 Kalle Valo wrote:
> >> Pali Rohár <pali.rohar@gmail.com> writes:
> >> 
> >> >> So
> >> >> for those other platforms there will be a delay waiting for user-mode
> >> >> helper to fail, before trying to get nvs file from /lib/firmware.
> >> >
> >> > Yes, there will be. But there is no easy way to fix this problem that
> >> > kernel is trying to use default/example NVS data...
> >> 
> >> Kernel is doing correctly and requesting NVS data as expected, the
> >> problem here is that linux-firmware claims that the example NVS data is
> >> real calibration data (which it is not). Distros should not use that,
> >> only developers for testing purposes. We should not courage users using
> >> example calibration data.
> >> 
> >> The simple fix is to rename the NVS file in linux-firmware to something
> >> like wl1251-nvs.bin.example, no need to workaround this in kernel. If
> >> you send a patch to linux-firmware I'm happy to ack that.
> >
> > I agree with rename and fact that default/example data should not be
> > used.
> >
> > But...
> >
> > 1) Kernel should not read device/model specific data from VFS where
> > are stored not-device-specific files preinstalled by linux
> > distributions.
> >
> > And linux distributions are already putting files into VFS and kernel
> > cannot enforce userspace to not do that (as they are already doing it).
> 
> I'm having problems to understand what you are saying here.

I'm saying that linux distributions are putting files to /lib/firmware
which comes from some sources already released. You cannot force linux
distributions to stop putting particular file to /lib/firmware *now*
after it was already released and recommended.

> > 2) It was already tested that example NVS data can be used for N900 e.g.
> > for SSH connection. If real correct data are not available it is better
> > to use at least those example (and probably log warning message) so user
> > can connect via SSH and start investigating where is problem.
> 
> I disagree. Allowing default calibration data to be used can be
> unnoticed by user and left her wondering why wifi works so badly.

So there are only two options:

1) Disallow it and so these users will have non-working wifi.

2) Allow those data to be used as fallback mechanism.

And personally I'm against 1) because it will break wifi support for
*all* Nokia N900 devices right now.

> > 3) If we do rename *now* we will totally break wifi support on Nokia
> > N900.
> 
> Then the distro should fix that when updating the linux-firmware
> packages. Can you provide details about the setup, what distro etc?

Debian stable, Ubuntu LTSs 14.04, 16.04. And I think that other
LTS distributions contains that example nvs file too (I'm not going to
verify others, but list will be probably long). Upgrading linux-firmware
is against policy of those distributions. So no this is not an solution.

-- 
Pali Rohár
pali.rohar@gmail.com
