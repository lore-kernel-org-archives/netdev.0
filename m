From: Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v3 3/5] net: asix: Fix AX88772x resume failures
Date: Thu, 10 Nov 2016 12:01:03 +0000
Message-ID: <77fa76d6-ef63-47db-a316-93b3a0c0705b@nvidia.com>
References: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss@collabora.com>
 <c708db3f1e006df543284cf5215b965ce4fc44ec.1472155176.git-series.robert.foss@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>, <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
        <Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>, <Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>, <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        <changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <c708db3f1e006df543284cf5215b965ce4fc44ec.1472155176.git-series.robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Robert,

On 29/08/16 14:32, robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org wrote:
> From: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> 
> From: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
> 
> The change fixes AX88772x resume failure by
> - Restore incorrect AX88772A PHY registers when resetting
> - Need to stop MAC operation when suspending
> - Need to restart MII when restoring PHY
> 
> Signed-off-by: Allan Chou <allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
> Signed-off-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> Tested-by: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>

After this commit, I have started seeing the following messages
during system suspend on various tegra boards using asix ethernet
dongles ...

[  288.667010] PM: Syncing filesystems ... done.
[  288.672223] Freezing user space processes ... (elapsed 0.001 seconds) done.
[  288.680505] Double checking all user space processes after OOM killer disable... (elapsed 0.000 seconds) 
[  288.690193] Freezing remaining freezable tasks ... (elapsed 0.001 seconds) done.
[  288.698987] Suspending console(s) (use no_console_suspend to debug)
[  288.706605] asix 1-1:1.0 eth0: Failed to read reg index 0x0000: -19
[  288.706613] asix 1-1:1.0 eth0: Error reading Medium Status register: ffffffed
[  288.706621] asix 1-1:1.0 eth0: Failed to write reg index 0x0000: -19
[  288.706629] asix 1-1:1.0 eth0: Failed to write Medium Mode mode to 0xfeed: ffffffed
[  288.759167] PM: suspend of devices complete after 52.772 msecs

Interestingly, it only seems to happen if the ethernet is in a
disconnected state when entering suspend. I have not had chance
to look at this any further, but wanted to see if you had any
thoughts.

Cheers
Jon

-- 
nvpublic
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
