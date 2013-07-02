From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 net-next] net: convert lls to use time_in_range()
Date: Tue, 2 Jul 2013 21:10:35 +0100
Message-ID: <1372795835.1919.14.camel@bwh-desktop.uk.level5networks.com>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com>
	 <20130701.140833.1705666564717621661.davem@davemloft.net>
	 <51D2919F.7050007@linux.intel.com> <51D29329.4060004@linux.intel.com>
	 <51D2A246.3000705@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <willemb@google.com>,
	<erdnetdev@gmail.com>, <andi@firstfloor.org>, <hpa@zytor.com>,
	<devel-lists@codyps.com>, <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51D2A246.3000705@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-07-02 at 12:49 +0300, Eliezer Tamir wrote:
> Time in range will fail safely if we move to a different cpu with an
> extremely large clock skew.
> Add time_in_range64() and convert lls to use it.
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> ---
> v1->v2
> fixed double call to sched_clock() in can_poll_ll(), checkpatchisms
[...]
> --- a/include/linux/jiffies.h
> +++ b/include/linux/jiffies.h
> @@ -139,6 +139,10 @@ static inline u64 get_jiffies_64(void)
>   	 ((__s64)(a) - (__s64)(b) >= 0))
>   #define time_before_eq64(a,b)	time_after_eq64(b,a)
> 
> +#define time_in_range64(a, b, c) \
> +	(time_after_eq64(a, b) && \
> +	 time_before_eq64(a, c))
[...]

Why not make this an inline function, so the caller doesn't need to
worry about repeated evaluation?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
