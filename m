From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH 1/2] IPV6: use ipv6_addr_any()
Date: Wed, 28 Jan 2004 12:57:27 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401281256260.21205-100000@netcore.fi>
References: <20040128.163043.120256112.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040128.163043.120256112.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> Use simple ipv6_addr_any()
> where ipv6_addr_type() is called only to check for unspecified address.

Speakign of which, should it be better to change this to _unspecified
if we're changing this as one could be led to believe that "any"  
refers to "any IPv6 address" which is obviously not the case.

> ===== net/ipv6/af_inet6.c 1.60 vs edited =====
> --- 1.60/net/ipv6/af_inet6.c	Thu Jan 22 15:38:40 2004
> +++ edited/net/ipv6/af_inet6.c	Wed Jan 28 16:11:31 2004
> @@ -464,7 +464,7 @@
>  		if (np->sndflow)
>  			sin->sin6_flowinfo = np->flow_label;
>  	} else {
> -		if (ipv6_addr_type(&np->rcv_saddr) == IPV6_ADDR_ANY)
> +		if (ipv6_addr_any(&np->rcv_saddr))
>  			ipv6_addr_copy(&sin->sin6_addr, &np->saddr);
>  		else
>  			ipv6_addr_copy(&sin->sin6_addr, &np->rcv_saddr);
> ===== net/ipv6/ndisc.c 1.64 vs edited =====
> --- 1.64/net/ipv6/ndisc.c	Thu Jan 22 15:38:40 2004
> +++ edited/net/ipv6/ndisc.c	Wed Jan 28 16:13:21 2004
> @@ -544,7 +544,7 @@
>  	}
>  
>  	len = sizeof(struct icmp6hdr) + sizeof(struct in6_addr);
> -	send_llinfo = dev->addr_len && ipv6_addr_type(saddr) != IPV6_ADDR_ANY;
> +	send_llinfo = dev->addr_len && !ipv6_addr_any(saddr);
>  	if (send_llinfo)
>  		len += NDISC_OPT_SPACE(dev->addr_len);
>  
> 
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
