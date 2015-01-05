From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/7] timecounter: provide a macro to initialize
 the cyclecounter mask field.
Date: Mon, 5 Jan 2015 13:20:57 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC09D7@AcuExch.aculab.com>
References: <cover.1420108214.git.richardcochran@gmail.com>
 <1f1bee3e2aa0cc530d006d99a621992a1497a442.1420108214.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: 'Richard Cochran' <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.185]:59123 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753868AbbAENV4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 08:21:56 -0500
In-Reply-To: <1f1bee3e2aa0cc530d006d99a621992a1497a442.1420108214.git.richardcochran@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There is no need for users of the timecounter/cyclecounter code to include
> clocksource.h just for a single macro.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  include/linux/timecounter.h |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/timecounter.h b/include/linux/timecounter.h
> index 74f4549..4382035 100644
> --- a/include/linux/timecounter.h
> +++ b/include/linux/timecounter.h
> @@ -19,6 +19,9 @@
> 
>  #include <linux/types.h>
> 
> +/* simplify initialization of mask field */
> +#define CYCLECOUNTER_MASK(bits) (cycle_t)((bits) < 64 ? ((1ULL<<(bits))-1) : -1)

That has me chasing through the C integer promotion rules.
Better might be:
	((bits) < 64 ? (1ULL << (bits)) - 1 : (((1ULL << 63) - 1) << 1) + 1)
I actually suspect there is a standard definition somewhere?

	David 
