From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/3 v2] ipv6: rename ADBG() to pr_xxx()
Date: Tue, 13 Aug 2013 13:37:19 +0200
Message-ID: <20130813113719.GF27385@order.stressinduktion.org>
References: <5209E6E8.1030702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Joe Perches <joe@perches.com>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48523 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab3HMLhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 07:37:20 -0400
Content-Disposition: inline
In-Reply-To: <5209E6E8.1030702@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 03:57:28PM +0800, Ding Tianhong wrote:
> According to Joe Perches opinions, the ADBG() was tedious and it is
> better to remove the KERN_<LEVEL>s and use the pr_xxx() instead of ADBG().
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> Cc: Joe Perches <joe@perches.com>
> ---
>  net/ipv6/addrconf.c | 29 +++++++++--------------------
>  1 file changed, 9 insertions(+), 20 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 72911fd..2333fa7 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -95,15 +95,6 @@
>  #include <linux/seq_file.h>
>  #include <linux/export.h>
>  
> -/* Set to 3 to get tracing... */
> -#define ACONF_DEBUG 2
> -
> -#if ACONF_DEBUG >= 3
> -#define ADBG(x) printk x

Please either change this to pr_warning, pr_err.

> -#else
> -#define ADBG(x)
> -#endif
> -
>  #define	INFINITY_LIFE_TIME	0xFFFFFFFF
>  
>  static inline u32 cstamp_delta(unsigned long cstamp)
> @@ -369,9 +360,8 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
>  	dev_hold(dev);
>  
>  	if (snmp6_alloc_dev(ndev) < 0) {
> -		ADBG((KERN_WARNING
> -			"%s: cannot allocate memory for statistics; dev=%s.\n",
> -			__func__, dev->name));
> +		pr_warning("%s: cannot allocate memory for statistics; dev=%s.\n",
> +			__func__, dev->name);

Or these to pr_debug/pr_dbg (for use with dynamic_debug).

I don't think it gives an advantage to emit debug messages which were designed
solely for debugging purposes before.

I would actually favour the dynamic_debug method.

Greetings,

  Hannes
