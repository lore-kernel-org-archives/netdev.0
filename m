From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Fri, 27 Jan 2017 16:41:25 +0100
Message-ID: <20170127154125.GL24223@pali>
References: <20170127094342.GC24223@pali>
 <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
 <20170127101043.GD24223@pali>
 <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
 <20170127103408.GG24223@pali>
 <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
 <20170127115706.GH24223@pali>
 <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
 <20170127131146.GI24223@pali>
 <87bmus5xyc.fsf@kamboji.qca.qualcomm.com>
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
In-Reply-To: <87bmus5xyc.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 27 January 2017 17:23:07 Kalle Valo wrote:
> Pali Rohár <pali.rohar@gmail.com> writes:
> 
> > On Friday 27 January 2017 14:26:22 Kalle Valo wrote:
> >> Pali Rohár <pali.rohar@gmail.com> writes:
> >> 
> >> > 2) It was already tested that example NVS data can be used for N900 e.g.
> >> > for SSH connection. If real correct data are not available it is better
> >> > to use at least those example (and probably log warning message) so user
> >> > can connect via SSH and start investigating where is problem.
> >> 
> >> I disagree. Allowing default calibration data to be used can be
> >> unnoticed by user and left her wondering why wifi works so badly.
> >
> > So there are only two options:
> >
> > 1) Disallow it and so these users will have non-working wifi.
> >
> > 2) Allow those data to be used as fallback mechanism.
> >
> > And personally I'm against 1) because it will break wifi support for
> > *all* Nokia N900 devices right now.
> 
> All two of them? :)

Ehm...

> But not working is exactly my point, if correct calibration data is not
> available wifi should not work. And it's not only about functionality
> problems, there's also the regulatory aspect.

About functionality, Pavel confirmed too that SSH is somehow working...

Regulatory aspect is different, but via iw can be manually configured
some settings.

> >> > 3) If we do rename *now* we will totally break wifi support on Nokia
> >> > N900.
> >> 
> >> Then the distro should fix that when updating the linux-firmware
> >> packages. Can you provide details about the setup, what distro etc?
> >
> > Debian stable, Ubuntu LTSs 14.04, 16.04. 
> 
> You can run these out of box on N900?

Out-of-box I can run Kubuntu 12.04 (which is LTS too). They had prepared
special image for N900 and I still have it on uSD card.

I guess that new versions of Ubuntu could somehow work (maybe not
out-of-box but with some changes) and Pavel has working Debian.

Also basic support needed for wifi and SSH server is probably working
with any distribution targeting armv7-a or omap3. So yes, I can say it
is out-of-box. We will not have GSM calls or camera support, but wifi
breakage is there.

> > And I think that other LTS distributions contains that example nvs
> > file too (I'm not going to verify others, but list will be probably
> > long). Upgrading linux-firmware is against policy of those
> > distributions. So no this is not an solution.
> 
> So instead we should workaround distro policies in kernel? Come on.
> 
> Seriously, just rename the file in linux-firmware and file a bug (with a
> patch) to distros. If they don't fix the bug you just have to do a
> custom hack for N900. But such is life.

I do not see point what will be changed. I rename that file and after
system update (or integrity check) it will be there again.

And if I do that, what prevents kernel to stop using NVS file from
/lib/firmware/? Nothing, original problem (which is going solved by this
patch series) still remains.

-- 
Pali Rohár
pali.rohar@gmail.com
