From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 5/5] net: sfc: avoid using timespec
Date: Wed, 30 Sep 2015 09:26:01 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509300925420.4500@nanos>
References: <1443471692-2946597-1-git-send-email-arnd@arndb.de> <1443471692-2946597-6-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: y2038@lists.linaro.org, John Stultz <john.stultz@linaro.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rodolfo Giometti <giometti@enneenne.com>,
	linux-net-drivers@solarflare.com,
	Shradha Shah <sshah@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443471692-2946597-6-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Sep 2015, Arnd Bergmann wrote:

> The sfc driver internally uses a time format based on 32-bit (unsigned)
> seconds and 32-bit nanoseconds. This means it will overflow in 2106,
> but the value we pass into it is a signed 32-bit tv_sec that already
> overflows in 2038 to a negative value.
> 
> This patch changes the logic to use the lower 32 bits of the timespec64
> tv_sec in efx_ptp_ns_to_s_ns, which will have the correct value beyond the overflow.
> While this does not change any of the register values, it lets us
> keep using the driver after we deprecate the use of the timespec type
> in the kernel.
> 
> In the efx_ptp_process_times function, the change to use timespec64
> is similar, in that the tv_sec portion is ignored anyway and we only
> care about the nanosecond portion that remains unchanged.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
