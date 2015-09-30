From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/5] ntp/pps: replace getnstime_raw_and_real with 64-bit
 version
Date: Wed, 30 Sep 2015 09:20:52 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509300920240.4500@nanos>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de> <1443471692-2946597-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: y2038@lists.linaro.org, John Stultz <john.stultz@linaro.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rodolfo Giometti <giometti@enneenne.com>,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:56835 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207AbbI3HVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 03:21:31 -0400
In-Reply-To: <1443471692-2946597-3-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Sep 2015, Arnd Bergmann wrote:

> There is exactly one caller of getnstime_raw_and_real in the kernel,
> which is the pps_get_ts function. This changes the caller and
> the implementation to work on timespec64 types rather than timespec,
> to avoid the time_t overflow on 32-bit architectures.
> 
> For consistency with the other new functions (ktime_get_seconds,
> ktime_get_real_*, ...), I'm renaming the function to
> ktime_get_raw_and_real_ts64.
> 
> We still need to convert from the internal 64-bit type to 32 bit
> types in the caller, but this conversion is now pushed out from
> getnstime_raw_and_real to pps_get_ts. A follow-up patch changes
> the remaining pps code to completely avoid the conversion.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
