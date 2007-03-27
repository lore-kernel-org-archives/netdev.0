From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-2.6.22] [IPV6] FIB6RULE: Find source address during looking up route.
Date: Tue, 27 Mar 2007 16:25:19 +0200
Message-ID: <20070327142519.GN521@postel.suug.ch>
References: <20070327.224537.09436398.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, takamiya@po.ntts.co.jp, netdev@vger.kernel.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56250 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882AbXC0OY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 10:24:58 -0400
Content-Disposition: inline
In-Reply-To: <20070327.224537.09436398.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* YOSHIFUJI Hideaki / ?$B5HF#1QL@ <yoshfuji@linux-ipv6.org> 2007-03-27 22:45
> When looking up route for destination with rules with
> source address restrictions, we may need to find a source
> address for the traffic if not given.

Out of curiosity, what sort of rules would have this flag set?
The majority of lookups don't provide a valid source address.
This new address search could become very expensive, because
none of the results are cached.

> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  include/linux/fib_rules.h |    7 +++++--
>  net/ipv6/fib6_rules.c     |   34 +++++++++++++++++++++++++++++++---
>  2 files changed, 36 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
> index 8270aac..2bbfa87 100644
> --- a/include/linux/fib_rules.h
> +++ b/include/linux/fib_rules.h
> @@ -5,8 +5,11 @@
>  #include <linux/rtnetlink.h>
>  
>  /* rule is permanent, and cannot be deleted */
> -#define FIB_RULE_PERMANENT	1
> -#define FIB_RULE_INVERT		2
> +#define FIB_RULE_PERMANENT	0x00000001
> +#define FIB_RULE_INVERT		0x00000002
> +
> +/* try to find source address in routing lookups */
> +#define	FIB_RULE_FIND_SADDR	0x00010000
>  
>  struct fib_rule_hdr
>  {

This chunk won't apply to latest net-2.6.22, I've added two more
flags yesterday.
