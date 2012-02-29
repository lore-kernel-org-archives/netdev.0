From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [Bug #42707] Hang deconfiguring network interface (in
 shutdown) on 3.3-rc1
Date: Wed, 29 Feb 2012 13:46:56 -0500 (EST)
Message-ID: <20120229.134656.2184805638060629954.davem@davemloft.net>
References: <20120228233225.GA1322@mcarlson.broadcom.com>
	<1330477116.2822.191.camel@dabdike.int.hansenpartnership.com>
	<1330508017.7993.3.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1330508017.7993.3.camel@HP1>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Date: Wed, 29 Feb 2012 01:33:37 -0800

> Subject: [PATCH net] tg3: Fix tg3_get_stats64 for 5700 / 5701 devs
> 
> From: Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> 
> tg3_get_stats64() takes tp->lock when dealing with non-serdes bcm5700
> and bcm5701 devices.  However, functions that call tg3_halt() have
> already acquired tp->lock.  When tg3_get_stats64() is called in
> tg3_halt(), deadlock will occur.
> 
> This patch fixes the problem by separating the stat gathering code into
> a new tg3_get_nstats() function.  tg3_get_stats64() is recoded to call
> this function and take tp->lock.  The code that takes tp->lock in
> tg3_calc_crc_errors() has been removed.  Function signatures have been
> cleaned up too.
> 
> Signed-off-by: Matt Carlson <mcarlson-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> Signed-off-by: Michael Chan <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

Applied, thanks everyone.
