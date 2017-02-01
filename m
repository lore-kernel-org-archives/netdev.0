From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Wed, 1 Feb 2017 09:33:12 +0100
Message-ID: <20170201083312.GA6609@pali>
References: <20170127103408.GG24223@pali>
 <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
 <20170127115706.GH24223@pali>
 <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
 <20170127131146.GI24223@pali>
 <87bmus5xyc.fsf@kamboji.qca.qualcomm.com>
 <20170127194012.GE20571@amd>
 <20170130175309.GY7403@atomide.com>
 <8737fzrb36.fsf@kamboji.qca.qualcomm.com>
 <20170131155918.GD7403@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>, Pavel Machek <pavel@ucw.cz>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35477 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751679AbdBAIdU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 03:33:20 -0500
Content-Disposition: inline
In-Reply-To: <20170131155918.GD7403@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 31 January 2017 07:59:18 Tony Lindgren wrote:
> * Kalle Valo <kvalo@codeaurora.org> [170130 22:36]:
> > Tony Lindgren <tony@atomide.com> writes:
> > 
> > > * Pavel Machek <pavel@ucw.cz> [170127 11:41]:
> > >> On Fri 2017-01-27 17:23:07, Kalle Valo wrote:
> > >> > Pali Rohár <pali.rohar@gmail.com> writes:
> > >> > 
> > >> > > On Friday 27 January 2017 14:26:22 Kalle Valo wrote:
> > >> > >> Pali Rohár <pali.rohar@gmail.com> writes:
> > >> > >> 
> > >> > >> > 2) It was already tested that example NVS data can be used for N900 e.g.
> > >> > >> > for SSH connection. If real correct data are not available it is better
> > >> > >> > to use at least those example (and probably log warning message) so user
> > >> > >> > can connect via SSH and start investigating where is problem.
> > >> > >> 
> > >> > >> I disagree. Allowing default calibration data to be used can be
> > >> > >> unnoticed by user and left her wondering why wifi works so badly.
> > >> > >
> > >> > > So there are only two options:
> > >> > >
> > >> > > 1) Disallow it and so these users will have non-working wifi.
> > >> > >
> > >> > > 2) Allow those data to be used as fallback mechanism.
> > >> > >
> > >> > > And personally I'm against 1) because it will break wifi support for
> > >> > > *all* Nokia N900 devices right now.
> > >> > 
> > >> > All two of them? :)
> > >> 
> > >> Umm. You clearly want a flock of angry penguins at your doorsteps :-).
> > >
> > > Well this silly issue of symlinking and renaming nvs files in a standard
> > > Linux distro was also hitting me on various devices with wl12xx/wl18xx
> > > trying to use the same rootfs.
> > >
> > > Why don't we just set a custom compatible property for n900 that then
> > > picks up some other nvs file instead of the default?
> > 
> > Please don't. An ugly kernel workaround in kernel because of user space
> > problems is a bad idea. wl1251 should just ask for NVS file from user
> > space, it shouldn't care if it's a "default" file or something else.
> > That's a user space policy decision.
> 
> Grr I keep forgetting it needs to be for each device manufactured so
> yeah that won't work.
> 
> The names of standard distro files are hardcoded into the kernel
> driver so it's also a kernel problem though :p
> 
> How about a custom devices tree property saying "needs-custom-firmware"?

How does it help request_firmware() call which automatically loads
firmware file from VFS (if is available)?

> Something that would prevent anything being loaded until user space
> loads the firmware. It could also be set in the driver automatically
> based on the compatible flag if we always want it enabled. And we could
> have some cmdline option to ignore it. Or the other way around whatever
> makes sense.

So you just want to kernel automatically prevent loading firmware file
(based on flag which driver can set). That is similar approach as mine.

> > Why can't you do something like this:
> > 
> > * rename the NVS file linux-firmware to wl1251-nvs.bin.example
> 
> As that name is hardcoded in the kernel and that file is provided by
> all standard distros, let's assume we just have to deal with that ABI
> forever.

Yes.

> > * before distro updates linux-firmware create yours own deb/rpm/whatever
> >   package "wl1251-firmware" which installs your flavor of nvs file (or
> >   the user fallback helper if more dynamic functionality is preferred)
> 
> And that won't work when using the same file system on other machines.
> 
> Think NFSroot for example. At least I'm using the same NFSroot across
> about 15 different machines including one n900 macro board with smc91x
> Ethernet.

Exactly problem which we already discussed in previous emails. You
cannot serve one file (loaded by direct request_firmware) when your
rootfs is readonly, e.g. comes via NFS shared for more devices...

-- 
Pali Rohár
pali.rohar@gmail.com
