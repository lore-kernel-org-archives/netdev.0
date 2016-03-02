From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 02 Mar 2016 14:35:39 -0800
Message-ID: <1456958139.648.116.camel@edumazet-ThinkPad-T530>
References: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35396 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755037AbcCBWfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 17:35:42 -0500
Received: by mail-pf0-f181.google.com with SMTP id w128so2005418pfb.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 14:35:42 -0800 (PST)
In-Reply-To: <1456957112-2702469-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On mer., 2016-03-02 at 14:18 -0800, Tom Herbert wrote:
\
> +	asm("lea 0f(, %[slen], 4), %%r11\n\t"
> +	    "clc\n\t"
> +	    "jmpq *%%r11\n\t"
> +	    "adcq 7*8(%[src]),%[res]\n\t"
> +	    "adcq 6*8(%[src]),%[res]\n\t"
> +	    "adcq 5*8(%[src]),%[res]\n\t"
> +	    "adcq 4*8(%[src]),%[res]\n\t"
> +	    "adcq 3*8(%[src]),%[res]\n\t"
> +	    "adcq 2*8(%[src]),%[res]\n\t"
> +	    "adcq 1*8(%[src]),%[res]\n\t"
> +	    "adcq 0*8(%[src]),%[res]\n\t"
> +	    "nop\n\t"
> +	    "0: adcq $0,%[res]"
> +		    : [res] "=r" (result)
> +		    : [src] "r" (buff),
> +		      [slen] "r" (-(unsigned long)(len >> 3)), "[res]" (result)
> +		    : "r11");
>  


hpa mentioned we could use adcq.d8 0*8(%[src]),%[res]

to avoid the mandatory 'nop'
