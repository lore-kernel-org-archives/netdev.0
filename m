From: Eldad Zack <eldad@fogrefinery.com>
Subject: Re: [patch net/stable] ipv6/exthdrs: accept tlv which includes only
 padding
Date: Sat, 7 Sep 2013 14:31:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1309071427120.1262@heraclitus>
References: <1378476145-6282-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:42478 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab3IGMbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 08:31:47 -0400
Received: by mail-bk0-f51.google.com with SMTP id mx10so1646919bkb.24
        for <netdev@vger.kernel.org>; Sat, 07 Sep 2013 05:31:46 -0700 (PDT)
In-Reply-To: <1378476145-6282-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Jiri,

On Fri, 6 Sep 2013, Jiri Pirko wrote:

> In rfc4942 and rfc2460 I cannot find anything which would implicate to
> drop packets which have only padding in tlv.

NAK from my side.
Please read RFC4942 2.1.9.5 "Misuse of Pad1 and PadN Options".

While it doesn't specifically discusses this corner case, you can 
understand from "There is no legitimate reason for padding beyond the 
next eight octet..." that there's also no legitimate reason for an 
option header containing only padding.
I can't imagine a sane use-case for this.

> Current behaviour breaks TAHI Test v6LC.1.2.6.

I'm not familiar with this, but IMHO the test should be reversed :)

Cheers,
Eldad

> 
> Problem was intruduced in:
> 9b905fe6843 "ipv6/exthdrs: strict Pad1 and PadN check"
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/ipv6/exthdrs.c | 6 ------
>  1 file changed, 6 deletions(-)
> 
> diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
> index 07a7d65..8d67900 100644
> --- a/net/ipv6/exthdrs.c
> +++ b/net/ipv6/exthdrs.c
> @@ -162,12 +162,6 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
>  		off += optlen;
>  		len -= optlen;
>  	}
> -	/* This case will not be caught by above check since its padding
> -	 * length is smaller than 7:
> -	 * 1 byte NH + 1 byte Length + 6 bytes Padding
> -	 */
> -	if ((padlen == 6) && ((off - skb_network_header_len(skb)) == 8))
> -		goto bad;
>  
>  	if (len == 0)
>  		return true;
> -- 
> 1.8.3.1
> 
