From: Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [net-next PATCH v2] drivers: net: cpsw: Add support to make gpio
 drive which slave connected to phy
Date: Thu, 3 Sep 2015 08:22:06 -0700
Message-ID: <20150903152205.GV4215@atomide.com>
References: <1441260115-16219-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1441260115-16219-1-git-send-email-mugunthanvnm-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org> [150902 23:05]:
> In DRA72x EVM, by default slave 1 is connected to the onboard
> phy, but slave 2 pins are also muxed with video input module
> which is controlled by pcf857x gpio and currently to select slave
> 0 to connect to phy gpio hogging is used, but with
> omap2plus_defconfig the pcf857x gpio is built as module. So when
> using NFS on DRA72x EVM, board doesn't boot as gpio hogging do
> not set proper gpio state to connect slave 0 to phy as it is
> built as module and you do not see any errors for not setting
> gpio and just mentions dhcp reply not got.
> 
> To solve this issue, introducing "mode-gpio" in DT when gpio
> based muxing is required. This will throw a warning when gpio
> get fails and returns probe defer. When gpio-pcf857x module is
> installed, cpsw probes again and ethernet becomes functional.
> Verified this on DRA72x with pcf as module and ramdisk.

Hmm you might be able to make it even a little bit more generic.
The gpios can be an array.. So typically they're named "-gpios":

[linux] $ git grep "\-gpio " arch/arm/boot/dts/*.dts* | wc -l
219
[linux] $ git grep "\-gpios " arch/arm/boot/dts/*.dts* | wc -l
704

So I'd use mode-gpios even though there's just one gpio in
this case. Up to you though, and should be retested after
the change naturally. At some point gpio code was not parsing
"gpio" or "gpios" properly.. But that's probably been fixed
a long time ago.

Regards,

Tony
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
