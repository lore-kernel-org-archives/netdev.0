From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for loading NVS calibration data
Date: Fri, 27 Jan 2017 14:26:22 +0200
Message-ID: <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
        <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
        <87tw8lnei3.fsf@codeaurora.org> <20170127094342.GC24223@pali>
        <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
        <20170127101043.GD24223@pali>
        <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
        <20170127103408.GG24223@pali>
        <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
        <20170127115706.GH24223@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
        Grazvydas Ignotas <notasas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170127115706.GH24223@pali> ("Pali \=\?utf-8\?Q\?Roh\=C3\=A1r\=22'\?\=
 \=\?utf-8\?Q\?s\?\= message of "Fri, 27
        Jan 2017 12:57:06 +0100")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Friday 27 January 2017 13:49:03 Kalle Valo wrote:
>> Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>=20
>> >> So
>> >> for those other platforms there will be a delay waiting for user-mode
>> >> helper to fail, before trying to get nvs file from /lib/firmware.
>> >
>> > Yes, there will be. But there is no easy way to fix this problem that
>> > kernel is trying to use default/example NVS data...
>>=20
>> Kernel is doing correctly and requesting NVS data as expected, the
>> problem here is that linux-firmware claims that the example NVS data is
>> real calibration data (which it is not). Distros should not use that,
>> only developers for testing purposes. We should not courage users using
>> example calibration data.
>>=20
>> The simple fix is to rename the NVS file in linux-firmware to something
>> like wl1251-nvs.bin.example, no need to workaround this in kernel. If
>> you send a patch to linux-firmware I'm happy to ack that.
>
> I agree with rename and fact that default/example data should not be
> used.
>
> But...
>
> 1) Kernel should not read device/model specific data from VFS where
> are stored not-device-specific files preinstalled by linux
> distributions.
>
> And linux distributions are already putting files into VFS and kernel
> cannot enforce userspace to not do that (as they are already doing it).

I'm having problems to understand what you are saying here.

> 2) It was already tested that example NVS data can be used for N900 e.g.
> for SSH connection. If real correct data are not available it is better
> to use at least those example (and probably log warning message) so user
> can connect via SSH and start investigating where is problem.

I disagree. Allowing default calibration data to be used can be
unnoticed by user and left her wondering why wifi works so badly.

> 3) If we do rename *now* we will totally break wifi support on Nokia
> N900.

Then the distro should fix that when updating the linux-firmware
packages. Can you provide details about the setup, what distro etc?

--=20
Kalle Valo
