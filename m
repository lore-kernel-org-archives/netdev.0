From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@wide.ad.jp>
Subject: Re: [PATCH] IPSec: IPv6 source address not set correctly in
 xfrm_state
Date: Sat, 22 Mar 2003 00:26:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030322.002624.32606907.yoshfuji@wide.ad.jp>
References: <1048258764.1214.28.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <1048258764.1214.28.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

In article <1048258764.1214.28.camel@tomlt2.tomloffice.austin.ibm.com> (at 21 Mar 2003 08:59:23 -0600), Tom Lendacky <toml@us.ibm.com> says:

>  			memcpy(&x->id.daddr, daddr, sizeof(x->sel.daddr));
>  		memcpy(&x->props.saddr, &tmpl->saddr, sizeof(x->props.saddr));
>  		if (ipv6_addr_any((struct in6_addr*)&x->props.saddr))
> -			memcpy(&x->props.saddr, &saddr, sizeof(x->sel.saddr));
> +			memcpy(&x->props.saddr, saddr, sizeof(x->props.saddr));

this fix is ok. however

>  		atomic_inc(&x0->refcnt);
>  	} else if (create && (x0 = xfrm_state_alloc()) != NULL) {
> -		memcpy(x0->sel.daddr.a6, daddr, sizeof(struct in6_addr));
> -		memcpy(x0->sel.saddr.a6, saddr, sizeof(struct in6_addr));
> +		memcpy(&x0->sel.daddr.a6, daddr, sizeof(struct in6_addr));
> +		memcpy(&x0->sel.saddr.a6, saddr, sizeof(struct in6_addr));
>  		x0->sel.prefixlen_d = 128;
>  		x0->sel.prefixlen_s = 128;
> -		memcpy(x0->props.saddr.a6, saddr, sizeof(struct in6_addr));
> +		memcpy(&x0->props.saddr.a6, saddr, sizeof(struct in6_addr));
>  		x0->km.state = XFRM_STATE_ACQ;
> -		memcpy(x0->id.daddr.a6, daddr, sizeof(struct in6_addr));
> +		memcpy(&x0->id.daddr.a6, daddr, sizeof(struct in6_addr));
>  		x0->id.proto = proto;
>  		x0->props.family = AF_INET6;
>  		x0->props.mode = mode;

these are not correct.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
