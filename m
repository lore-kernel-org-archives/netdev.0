From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH RESEND] memory leak in ndisc_router_discovery
Date: Mon, 16 Dec 2002 15:35:32 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021216.153532.87456123.yoshfuji@wide.ad.jp>
References: <200212121905.gBCJ5hn18058@eng2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
	krkumar@us.ibm.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <200212121905.gBCJ5hn18058@eng2.beaverton.ibm.com>
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
List-Id: netdev.vger.kernel.org

In article <200212121905.gBCJ5hn18058@eng2.beaverton.ibm.com> (at Thu, 12 Dec 2002 11:05:43 -0800 (PST)), Krishna Kumar <krkumar@us.ibm.com> says:

> I had sent this earlier, there is a bug in router advertisement handling code,
> where the reference (and memory) to an inet6_dev pointer can get leaked (this
> leak can happen atmost once for each interface on a system which receives
> invalid RA's). Below is the patch against 2.5.51 to fix it.

(It would be called "refcnt leakage," or some thing like that, but anyway)
This seems correct fix. please apply...

> -------------------------------------------------------------------------------
> diff -ruN linux.org/net/ipv6/ndisc.c linux/net/ipv6/ndisc.c
> --- linux.org/net/ipv6/ndisc.c	Fri Nov  7 10:02:11 2002
> +++ linux/net/ipv6/ndisc.c	Fri Nov  8 14:37:27 2002
> @@ -871,6 +871,7 @@
>  	}
>  
>  	if (!ndisc_parse_options(opt, optlen, &ndopts)) {
> +		in6_dev_put(in6_dev);
>  		if (net_ratelimit())
>  			ND_PRINTK2(KERN_WARNING
>  				   "ICMP6 RA: invalid ND option, ignored.\n");
> -------------------------------------------------------------------------------

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
