From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Fri, 27 Jan 2017 12:57:06 +0100
Message-ID: <20170127115706.GH24223@pali>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <87tw8lnei3.fsf@codeaurora.org>
 <20170127094342.GC24223@pali>
 <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
 <20170127101043.GD24223@pali>
 <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
 <20170127103408.GG24223@pali>
 <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36109 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934748AbdA0L5o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 06:57:44 -0500
Content-Disposition: inline
In-Reply-To: <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 27 January 2017 13:49:03 Kalle Valo wrote:
> Pali Rohár <pali.rohar@gmail.com> writes:
> 
> >> So
> >> for those other platforms there will be a delay waiting for user-mode
> >> helper to fail, before trying to get nvs file from /lib/firmware.
> >
> > Yes, there will be. But there is no easy way to fix this problem that
> > kernel is trying to use default/example NVS data...
> 
> Kernel is doing correctly and requesting NVS data as expected, the
> problem here is that linux-firmware claims that the example NVS data is
> real calibration data (which it is not). Distros should not use that,
> only developers for testing purposes. We should not courage users using
> example calibration data.
> 
> The simple fix is to rename the NVS file in linux-firmware to something
> like wl1251-nvs.bin.example, no need to workaround this in kernel. If
> you send a patch to linux-firmware I'm happy to ack that.

I agree with rename and fact that default/example data should not be
used.

But...

1) Kernel should not read device/model specific data from VFS where
are stored not-device-specific files preinstalled by linux
distributions.

And linux distributions are already putting files into VFS and kernel
cannot enforce userspace to not do that (as they are already doing it).

2) It was already tested that example NVS data can be used for N900 e.g.
for SSH connection. If real correct data are not available it is better
to use at least those example (and probably log warning message) so user
can connect via SSH and start investigating where is problem.

3) If we do rename *now* we will totally break wifi support on Nokia
N900.

-- 
Pali Rohár
pali.rohar@gmail.com
