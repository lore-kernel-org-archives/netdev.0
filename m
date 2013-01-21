From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/5 v2] soreuseport: TCP/IPv4 implementation
Date: Mon, 21 Jan 2013 11:30:25 +0900
Message-ID: <50FCA841.8020109@linux-ipv6.org>
References: <alpine.DEB.2.00.1301201542510.834@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk, eric.dumazet@gmail.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:49429 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752625Ab3AUCa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 21:30:26 -0500
In-Reply-To: <alpine.DEB.2.00.1301201542510.834@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:

> +		} else if (score == hiscore && reuseport) {
> +			matches++;
> +			if (((u64)phash * matches) >> 32 == 0)
> +				result = sk;
> +			phash = next_pseudo_random32(phash);
>  		}
>  	}
>  	/*

Well, honestly, this seems the most difficult part to understand
at a glance.  Plus, there seems multiple ways to do this.
Maybe, inline?

static inline sock_true_1_in_n(u32 r, unsigned int n)
{
	/* return (r < ~0U / n); */
	/* return (r % n == 0); */
	return ((u64)r * n >> 32) == 0;
}
