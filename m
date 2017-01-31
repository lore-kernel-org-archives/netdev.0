From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for loading NVS calibration data
Date: Tue, 31 Jan 2017 08:35:09 +0200
Message-ID: <8737fzrb36.fsf@kamboji.qca.qualcomm.com>
References: <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
        <20170127101043.GD24223@pali>
        <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
        <20170127103408.GG24223@pali>
        <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
        <20170127115706.GH24223@pali>
        <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
        <20170127131146.GI24223@pali>
        <87bmus5xyc.fsf@kamboji.qca.qualcomm.com> <20170127194012.GE20571@amd>
        <20170130175309.GY7403@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
        Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Arend Van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>,
        Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
        Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Aaro Koskinen <aaro.koskinen-X3B1VOXEql0@public.gmane.org>,
        Grazvydas Ignotas <notasas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170130175309.GY7403-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org> (Tony Lindgren's message of
        "Mon, 30 Jan 2017 09:53:09 -0800")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org> writes:

> * Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> [170127 11:41]:
>> On Fri 2017-01-27 17:23:07, Kalle Valo wrote:
>> > Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>> >=20
>> > > On Friday 27 January 2017 14:26:22 Kalle Valo wrote:
>> > >> Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>> > >>=20
>> > >> > 2) It was already tested that example NVS data can be used for N9=
00 e.g.
>> > >> > for SSH connection. If real correct data are not available it is =
better
>> > >> > to use at least those example (and probably log warning message) =
so user
>> > >> > can connect via SSH and start investigating where is problem.
>> > >>=20
>> > >> I disagree. Allowing default calibration data to be used can be
>> > >> unnoticed by user and left her wondering why wifi works so badly.
>> > >
>> > > So there are only two options:
>> > >
>> > > 1) Disallow it and so these users will have non-working wifi.
>> > >
>> > > 2) Allow those data to be used as fallback mechanism.
>> > >
>> > > And personally I'm against 1) because it will break wifi support for
>> > > *all* Nokia N900 devices right now.
>> >=20
>> > All two of them? :)
>>=20
>> Umm. You clearly want a flock of angry penguins at your doorsteps :-).
>
> Well this silly issue of symlinking and renaming nvs files in a standard
> Linux distro was also hitting me on various devices with wl12xx/wl18xx
> trying to use the same rootfs.
>
> Why don't we just set a custom compatible property for n900 that then
> picks up some other nvs file instead of the default?

Please don't. An ugly kernel workaround in kernel because of user space
problems is a bad idea. wl1251 should just ask for NVS file from user
space, it shouldn't care if it's a "default" file or something else.
That's a user space policy decision.

Why can't you do something like this:

* rename the NVS file linux-firmware to wl1251-nvs.bin.example

* before distro updates linux-firmware create yours own deb/rpm/whatever
  package "wl1251-firmware" which installs your flavor of nvs file (or
  the user fallback helper if more dynamic functionality is preferred)

--=20
Kalle Valo
