From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH wireless-2.6 or stable] iwlwifi: return error when fail
 to start scanning
Date: Wed, 6 Oct 2010 16:01:50 -0400
Message-ID: <20101006200150.GJ2472@tuxdriver.com>
References: <20101005085717.GA18012@redhat.com>
 <1286317292-10679-1-git-send-email-florian@mickler.org>
 <20101006090228.GA2523@redhat.com>
 <20101006160434.GB24581@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ben.m.cahill-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101006160434.GB24581-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 06, 2010 at 06:04:35PM +0200, Stanislaw Gruszka wrote:
> This is stable friendly backport of wireless-testing commit
> 3eecce527c7434dfd16517ce08b49632c8a26717 "iwlwifi: unify scan start
> checks". Wireless-testing version include also a lot of cleanups.
> 
> On error case in {iwl3945,iwlagn}_request_scan we queue abort_scan work,
> which in a fact do nothing, so we never complete the scan. Thats gives
> "WARNING: at net/wireless/core.c:614 wdev_cleanup_work" and stopped
> network connection until reload iwlwifi modules. Return of -EIO, and
> stopping queuing any work is a fix.
> 
> Note there are still many cases when we can get: 
> 
> WARNING: at net/wireless/core.c:614 wdev_cleanup_work  
> WARNING: at net/mac80211/scan.c:266 ieee80211_scan_completed
> WARNING: at net/mac80211/scan.c:269 ieee80211_scan_complete
> 
> which are not fixed. Unfortunately does not exist single, small fix
> for that problems, and we probably will see some more bug reports
> with scan warnings. As solution we rewrite iwl-scan.c code to avoid
> all possible race conditions. That quite big patch set is queued
> for 2.6.37 .
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
> Patch is intended for wireless-2.6, or in case when it does not
> make 2.6.36 release, for -stable 2.6.36.y 

I'm fine with this patch for -stable, but I'm not sure it is worthwhile
to rush it into 2.6.36.  The problem it fixes is intermittent and
not always very severe, and we've already been living with it for
4 releases.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
