From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Wed, 25 Apr 2007 06:55:39 +0900 (JST)
Message-ID: <20070425.065539.104129657.yoshfuji@linux-ipv6.org>
References: <20070425.011028.113320997.yoshfuji@linux-ipv6.org>
	<20070424183827.adb60ae0.dada1@cosmosbay.com>
	<20070424100420.2860db68@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, bunk@stusta.de, davem@davemloft.net,
	netdev@vger.kernel.org, tglx@linutronix.de, yoshfuji@linux-ipv6.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32905 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423127AbXDXVzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 17:55:45 -0400
In-Reply-To: <20070424100420.2860db68@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070424100420.2860db68@dxpl.pdx.osdl.net> (at Tue, 24 Apr 2007 10:04:20 -0700), Stephen Hemminger <shemminger@linux-foundation.org> says:

> Yoshifuji-san had the right idea, but ktime_to_us needs to be defined
> in a way that works on both 64 and 32bit platforms.

No, this does not cure.
>  
> +#define ktime_to_us(kt)			((kt).tv64 / NSEC_PER_SEC)
> +

NSEC_PER_USEC?

> +static inline s64 ktime_to_us(const ktime_t kt)
> +{
> +	return (s64) kt.tv_sec * USEC_PER_SEC + kt.tv_nsec / NSEC_PER_USEC;
> +}
> +

Please do NOT use division here, which was the source of the
linkage error, and the reason why I posted a patch to use
ktime_to_timeval().

--yoshfuji
