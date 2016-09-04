From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ti: cpmac: Fix compiler warning due to type
 confusion
Date: Sun, 04 Sep 2016 11:48:01 -0700 (PDT)
Message-ID: <20160904.114801.938788018799814156.davem@davemloft.net>
References: <20160902142248.3553-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: paul.burton@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160902142248.3553-1-paul.burton@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Burton <paul.burton@imgtec.com>
Date: Fri, 2 Sep 2016 15:22:48 +0100

> cpmac_start_xmit() used the max() macro on skb->len (an unsigned int)
> and ETH_ZLEN (a signed int literal). This led to the following compiler
> warning:
> 
>   In file included from include/linux/list.h:8:0,
>                    from include/linux/module.h:9,
>                    from drivers/net/ethernet/ti/cpmac.c:19:
>   drivers/net/ethernet/ti/cpmac.c: In function 'cpmac_start_xmit':
>   include/linux/kernel.h:748:17: warning: comparison of distinct pointer
>   types lacks a cast
>     (void) (&_max1 == &_max2);  \
>                    ^
>   drivers/net/ethernet/ti/cpmac.c:560:8: note: in expansion of macro 'max'
>     len = max(skb->len, ETH_ZLEN);
>           ^
> 
> On top of this, it assigned the result of the max() macro to a signed
> integer whilst all further uses of it result in it being cast to varying
> widths of unsigned integer.
> 
> Fix this up by using max_t to ensure the comparison is performed as
> unsigned integers, and for consistency change the type of the len
> variable to unsigned int.
> 
> Signed-off-by: Paul Burton <paul.burton@imgtec.com>

Applied.
