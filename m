From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC PATCH] net: wireless: move regulatory timeout work to power
 efficient workqueue
Date: Wed, 5 Feb 2014 04:25:12 -0500
Message-ID: <20140205092512.GB32349@htj.dyndns.org>
References: <1391123310-6425-1-git-send-email-zoran.markovic@linaro.org>
 <1391160084.4141.1.camel@jlt4.sipsolutions.net>
 <20140131093531.GA25559@mtj.dyndns.org>
 <20140205091742.GA1978@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Zoran Markovic <zoran.markovic-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shaibal Dutta <shaibal.dutta-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140205091742.GA1978-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Feb 05, 2014 at 10:17:42AM +0100, Stanislaw Gruszka wrote:
> What are selection criteria when choosing between system_wq or
> system_power_efficient_wq on drivers ? IOW if I would be writing
> a new driver which workqueue should I use and when ?

Yeah, it's a bit ad-hoc at the moment.  The original intention was
just marking the ones which can be shown to have noticeable power
impacts which weren't expected to be too many but we may now have an
self-feeding feedback loop growing new usages, likely somewhat
overzealously and be better off making things more generic.

> I think that should be driver independent, at least for most of drivers.
> If system have to run in low power mode, system_power_efficient_wq
> should be chosen automatically by schedule_work(), otherwise when high
> performance is more important schedule_work() should use system_wq.

The problem there is that system_wq has traditionally guaranteed
per-cpu execution.  It can't automatically be switched to unbound
behavior.  The best long term solution would be isolating the users
which depend on per-cpu behavior and mark them specially rather than
the other way around that we're doing now, making per-cpu guarantee
the special case rather than the norm.  That's gonna take a lot of
auditing tho.

Thanks.

-- 
tejun
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
