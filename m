From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for loading NVS calibration data
Date: Fri, 27 Jan 2017 13:49:03 +0200
Message-ID: <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
        <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
        <87tw8lnei3.fsf@codeaurora.org> <20170127094342.GC24223@pali>
        <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
        <20170127101043.GD24223@pali>
        <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
        <20170127103408.GG24223@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
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
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33162 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933013AbdA0LtR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 06:49:17 -0500
In-Reply-To: <20170127103408.GG24223@pali> ("Pali \=\?utf-8\?Q\?Roh\=C3\=A1r\=22'\?\=
 \=\?utf-8\?Q\?s\?\= message of "Fri, 27
        Jan 2017 11:34:08 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

>> So
>> for those other platforms there will be a delay waiting for user-mode
>> helper to fail, before trying to get nvs file from /lib/firmware.
>
> Yes, there will be. But there is no easy way to fix this problem that
> kernel is trying to use default/example NVS data...

Kernel is doing correctly and requesting NVS data as expected, the
problem here is that linux-firmware claims that the example NVS data is
real calibration data (which it is not). Distros should not use that,
only developers for testing purposes. We should not courage users using
example calibration data.

The simple fix is to rename the NVS file in linux-firmware to something
like wl1251-nvs.bin.example, no need to workaround this in kernel. If
you send a patch to linux-firmware I'm happy to ack that.

--=20
Kalle Valo
