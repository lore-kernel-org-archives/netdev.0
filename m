From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: Thu, 22 Jul 2004 20:04:26 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722.200426.99255296.yoshfuji@linux-ipv6.org>
References: <20040716103759.1928c2ae@dell_ss3.pdx.osdl.net>
	<200407172357.15832.arekm@pld-linux.org>
	<20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hadi@znyx.com, arekm@pld-linux.org, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net> (at Thu, 22 Jul 2004 13:45:22 -0700), Stephen Hemminger <shemminger@osdl.org> says:

> The recent changes to (6 Jul 04) pkt_cls.h are evil, you can't build a version
> of 'tc' to work unless you know the kernel config!
> 
> It has several API problems:
>   - API data structures change on kernel config options
>   - new fields should be added at the end of a structure to allow
>     binary compatibility.
    - We cannot add new variable(s) after the last member which is 
      an variable-length array in effect.

> @@ -229,11 +214,9 @@
>  
>  	short			hoff;
>  	__u32			hmask;
> -#ifdef CONFIG_CLS_U32_PERF
> +	struct tc_u32_key	keys[0];
>  	unsigned long		rcnt;
>  	unsigned long		rhit;
> -#endif
> -	struct tc_u32_key	keys[0];
>  };
>  
>  /* Flags */

We cannot do this because keys holds key of variable length.

Solutions are, for example,
 to allocate new TCA_U32_xxx for rcnt and rhit,
or, 
 to rename TCA_U32_SEL to TCA_U32_OLS_SEL and allocate new value for 
 TCA_U32_SEL.

--yoshfuji
