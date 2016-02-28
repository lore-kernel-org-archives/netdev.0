From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: Implement fast csum_partial for x86_64
Date: Sun, 28 Feb 2016 12:35:30 -0800
Message-ID: <1456691730.648.51.camel@edumazet-ThinkPad-T530>
References: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, tglx@linutronix.de,
	mingo@redhat.com, hpa@zytor.com, x86@kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34981 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831AbcB1Ugd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 15:36:33 -0500
Received: by mail-pa0-f48.google.com with SMTP id bj10so10121576pad.2
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2016 12:36:33 -0800 (PST)
In-Reply-To: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ven., 2016-02-26 at 12:03 -0800, Tom Herbert wrote:
> +
> +	/*
> +	 * Length is greater than 64. Sum to eight byte alignment before
> +	 * proceeding with main loop.
> +	 */
> +	aligned = !!((unsigned long)buff & 0x1);
> +	if (aligned) {
> +		unsigned int align = 7 & -(unsigned long)buff;
> +
> +		result = csum_partial_lt8_head(*(unsigned long *)buff, align);
> +		buff += align;
> +		len -= align;
> +		result = rotate_by8_if_odd(result, align);
> +	}
> +

This looks like you wanted to test 3 low order bits, not only the 1 low
order.

aligned = !((unsigned long)buff & 0x7);

if (!aligned) {
 ...
}

Or rename the variable to notaligned
