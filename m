From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] iplink_geneve: add UDP destination port configuration
 at link creation
Date: Thu, 17 Sep 2015 13:49:49 -0700
Message-ID: <1442522989.7946.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442518065-23294-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35551 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbbIQUtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 16:49:51 -0400
Received: by pacfv12 with SMTP id fv12so29407555pac.2
        for <netdev@vger.kernel.org>; Thu, 17 Sep 2015 13:49:51 -0700 (PDT)
In-Reply-To: <1442518065-23294-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-09-17 at 15:27 -0400, John W. Linville wrote:
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---

>  }
>  
> @@ -150,6 +159,10 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
>  		else
>  			fprintf(f, "tos %#x ", tos);
>  	}
> +
> +	if (tb[IFLA_GENEVE_PORT])
> +		fprintf(f, "dstport %u ",
> +			ntohs(rta_getattr_u16(tb[IFLA_GENEVE_PORT])));

This looks strange.

Kernel does :

if (nla_put_u16(skb, IFLA_GENEVE_PORT, ntohs(geneve->dst_port)))
        goto nla_put_failure;
