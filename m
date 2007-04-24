From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [net-2.6.22] [TCP]: Fix linkage errors.
Date: Tue, 24 Apr 2007 18:38:27 +0200
Message-ID: <20070424183827.adb60ae0.dada1@cosmosbay.com>
References: <20070425.001743.19811068.yoshfuji@linux-ipv6.org>
	<20070424155324.GL3468@stusta.de>
	<20070425.005845.113682267.yoshfuji@linux-ipv6.org>
	<20070425.011028.113320997.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, davem@davemloft.net, shemminger@osdl.org,
	netdev@vger.kernel.org, tglx@linutronix.de
To: YOSHIFUJI Hideaki / =?ISO-8859-1?B?X19fX19fX19fX19f?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:44308 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422722AbXDXQic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 12:38:32 -0400
In-Reply-To: <20070425.011028.113320997.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Apr 2007 01:10:28 +0900 (JST)
YOSHIFUJI Hideaki  <yoshfuji@linux-ipv6.org> wrote:

> How about this?
> 
>  
> +static inline s64 ktime_to_us(const ktime_t kt)
> +{
> +	struct timeval tv = ktime_to_timeval(kt);
> +	return tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
> +}
> +

Well, I am afraid it's not 100% correct.

If you really want to return s64 you should do

return (s64) tv.tv_sec * USEC_PER_SEC + tv.tv_usec;

But then it might be overkill to compute a full s64 for TCP use, since we use u32 vrtt

