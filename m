From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH v2] XFRM: assorted IPsec fixups
Date: Tue, 11 Dec 2007 09:19:57 -0800 (PST)
Message-ID: <20071211.091957.98044450.yoshfuji@linux-ipv6.org>
References: <20071211163019.15059.73746.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov, yoshfuji@linux-ipv6.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43508 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751661AbXLKRTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 12:19:31 -0500
In-Reply-To: <20071211163019.15059.73746.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20071211163019.15059.73746.stgit@flek.lan> (at Tue, 11 Dec 2007 11:30:19 -0500), Paul Moore <paul.moore@hp.com> says:

> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 5b860b6..e2a3dd1 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
:
> @@ -1994,67 +1995,59 @@ void __init xfrm_state_init(void)
>  static inline void xfrm_audit_common_stateinfo(struct xfrm_state *x,
>  					       struct audit_buffer *audit_buf)
>  {
> -	if (x->security)
> -		audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
> -				 x->security->ctx_alg, x->security->ctx_doi,
> -				 x->security->ctx_str);
> +	struct xfrm_sec_ctx *ctx = x->security;
> +	u32 spi = ntohl(x->id.spi);
>  
> -	switch(x->props.family) {
> -	case AF_INET:
> -		audit_log_format(audit_buf, " src=%u.%u.%u.%u dst=%u.%u.%u.%u",
> -				 NIPQUAD(x->props.saddr.a4),
> -				 NIPQUAD(x->id.daddr.a4));
> -		break;
> -	case AF_INET6:
> -		{
> -			struct in6_addr saddr6, daddr6;
> -
> -			memcpy(&saddr6, x->props.saddr.a6,
> -				sizeof(struct in6_addr));
> -			memcpy(&daddr6, x->id.daddr.a6,
> -				sizeof(struct in6_addr));
> -			audit_log_format(audit_buf,
> -					 " src=" NIP6_FMT " dst=" NIP6_FMT,
> -					 NIP6(saddr6), NIP6(daddr6));
> -		}
> -		break;
> -	}
> +        if (ctx)
> +                audit_log_format(audit_buf, " sec_alg=%u sec_doi=%u sec_obj=%s",
> +                                 ctx->ctx_alg, ctx->ctx_doi, ctx->ctx_str);
> +
> +        switch(x->props.family) {
> +        case AF_INET:
> +                audit_log_format(audit_buf,
> +				 " src=" NIPQUAD_FMT " dst=" NIPQUAD_FMT,
> +                                 NIPQUAD(x->props.saddr.a4),
> +                                 NIPQUAD(x->id.daddr.a4));
> +                break;
> +        case AF_INET6:
> +		audit_log_format(audit_buf,
> +				 " src=" NIP6_FMT " dst=" NIP6_FMT,
> +				 NIP6(*(struct in6_addr *)x->props.saddr.a6),
> +				 NIP6(*(struct in6_addr *)x->id.daddr.a6));
> +                break;
> +        }
> +
> +	audit_log_format(audit_buf, " spi=%u(0x%x)", spi, spi);
>  }
>  

Please do not mangle tabs into spaces.

--yoshfuji
