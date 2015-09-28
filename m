From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] net sysfs: Print link speed as signed integer
Date: Mon, 28 Sep 2015 15:00:31 +0200
Message-ID: <20150928130031.GA19923@breakpoint.cc>
References: <1443444529-12868-1-git-send-email-alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443444529-12868-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexander Stein <alexander.stein@systec-electronic.com> wrote:
> Otherwise 4294967295 (MBit/s) (-1) will be printed when there is no link.
> Documentation/ABI/testing/sysfs-class-net does not state if this shall be
> signed or unsigned.
> 
> Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
> ---
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 805a95a..e3f7eea 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -31,7 +31,7 @@
>  static const char fmt_hex[] = "%#x\n";
>  static const char fmt_long_hex[] = "%#lx\n";
>  static const char fmt_dec[] = "%d\n";
> -static const char fmt_udec[] = "%u\n";
> +static const char fmt_udec[] = "%d\n";
>  static const char fmt_ulong[] = "%lu\n";
>  static const char fmt_u64[] = "%llu\n";

That looks bogus.  If this is about 'speed' attribute
consider removing fmt_udec and replace the printf specifier
of speed_show with fmt_dec instead.
