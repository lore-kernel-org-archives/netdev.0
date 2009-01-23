From: Hannes Eder <hannes@hanneseder.net>
Subject: Re: [PATCH] Fix missing ifdef in isdn_ppp
Date: Fri, 23 Jan 2009 10:44:11 +0100
Message-ID: <154e089b0901230144o2b52c232kb93a71429fb258a9@mail.gmail.com>
References: <20090122221827.GA28623@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniele Venzano <venza@brownhat.org>,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Karsten Keil <kkeil@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:10534 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbZAWJoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 04:44:13 -0500
In-Reply-To: <20090122221827.GA28623@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add CC. I think this could go upstream via David Miller's net-2.6 tree.

Best,
Hannes

On Thu, Jan 22, 2009 at 11:18 PM, Karsten Keil <kkeil@suse.de> wrote:
> The following patch fixes a warning caused by a missing ifdef in
> isdn_ppp.c. A function was defined, but never used if CONFIG_IPPP_FILTER
> was not defined.
>
> The warning was: 'get_filter' defined but not used
> Patch is against 2.6.28.1
>
> Signed-off-by: Daniele Venzano <venza@brownhat.org>
> Acked-by: Karsten Keil <kkeil@suse.de>
>
> --- a/drivers/isdn/i4l/isdn_ppp.c       2009-01-22 15:01:27.000000000 +0100
> +++ b/drivers/isdn/i4l/isdn_ppp.c       2009-01-22 15:01:59.000000000 +0100
> @@ -431,6 +431,7 @@ set_arg(void __user *b, void *val,int le
>        return 0;
>  }
>
> +#ifdef CONFIG_IPPP_FILTER
>  static int get_filter(void __user *arg, struct sock_filter **p)
>  {
>        struct sock_fprog uprog;
> @@ -465,6 +466,7 @@ static int get_filter(void __user *arg,
>        *p = code;
>        return uprog.len;
>  }
> +#endif /* CONFIG_IPPP_FILTER */
>
>  /*
>  * ippp device ioctl
>
