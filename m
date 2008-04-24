From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Thu, 24 Apr 2008 01:08:45 -0700 (PDT)
Message-ID: <20080424.010845.257071066.davem@davemloft.net>
References: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33088
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750752AbYDXIIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:08:48 -0400
In-Reply-To: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Apr 2008 17:02:57 +0900 (JST)

> +#ifdef __KERNEL__
> +struct __compat_sockaddr_storage {
> +	unsigned short  ss_family;
> +	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
> +} __attribute__ ((aligned(4)));
> +#endif

Should include <linux/compat.h>, use compat types, and be guarded
by CONFIG_COMPAT.  This goes for all such structures.

>     [IPV6] COMPAT: group_filter{}-getsockopt compat layer.
>     
>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Where is ip6_mc_compat_msfget() header file declaration?

This following call casts the 5th argument to "struct group_filter"
but the argument type in the implementation is...

> +int ip6_mc_compat_msfget(struct sock *sk,
> +			 struct in6_addr *group,
> +			 u32 gf_interface, u32 gf_numsrc,
> +			 struct compat_group_filter __user *optval,
> +			 int __user *optlen)

"struct compat_group_filter".

You didn't catch this because you forgot to add the extern
prototype to the header file.  Actually, I wonder if you test
built this at all, as gcc should have warned about the lack of
extern declaration when compiling ipv6_sockglue.c

Thanks for doing this work, please make corrections and I also
look forward to your ipv4 side fixes.
