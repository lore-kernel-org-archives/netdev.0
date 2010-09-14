From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 2.6.36-rc4/iwl: warning triggered in net/mac80211/scan.c:266
Date: Tue, 14 Sep 2010 16:36:28 +0200
Message-ID: <1284474988.3704.10.camel@jlt3.sipsolutions.net>
References: <20100914142814.GA8744@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100914142814.GA8744-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-09-14 at 16:28 +0200, Michael S. Tsirkin wrote:
> I am running 2.6.36-rc4 on T60 with an iwlagn wireless card:
> 03:00.0 Network controller: Intel Corporation PRO/Wireless 5100 AGN [Shiloh] Network Connection
> 
> I was compiling a large file which stressed the box heavily, and the
> following warning in net/mac80211/scan.c triggered:
> 
>         /*
>          * It's ok to abort a not-yet-running scan (that
>          * we have one at all will be verified by checking
>          * local->scan_req next), but not to complete it
>          * successfully.
>          */
>         if (WARN_ON(!local->scanning && !aborted))
>                 aborted = true;
> 
> dmesg below:
> 
> [84379.361297] ------------[ cut here ]------------
> [84379.361307] WARNING: at net/mac80211/scan.c:266 ieee80211_scan_completed+0x43/0x17f()

> Should this happen? Does anyone care?
> I am not sure how reproducible this is.

No, it shouldn't happen. But there are various races in iwlwifi that can
cause this. Stanislaw has fixed them recently, but it's a fairly large
patchset. I'm not sure, but I don't think this is really new in .36.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
