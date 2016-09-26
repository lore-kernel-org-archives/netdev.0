From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 5/7] ipv6 addrconf: implement RFC7559 router
 solicitation backoff
Date: Mon, 26 Sep 2016 15:53:57 +0200
Message-ID: <f249b2b1-e19f-bbc6-d02e-b256fd369c16@stressinduktion.org>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com>
 <1474801390-6891-6-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:48381 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S941470AbcIZNyA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 09:54:00 -0400
In-Reply-To: <1474801390-6891-6-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.09.2016 13:03, Maciej Żenczykowski wrote:
> +static inline s32 rfc3315_s14_backoff_init(s32 initial)
> +{
> +	u32 r = (9 << 20) / 10 + (prandom_u32() % ((2 << 20) / 10 + 1));

^

> +	s32 v = initial * (u64)r >> 20;       /* ~ multiply by 0.9 .. 1.1 */
> +	return v;
> +}
> +
> +static inline s32 rfc3315_s14_backoff_update(s32 cur, s32 ceiling)
> +{
> +	u32 r = (19 << 20) / 10 + (prandom_u32() % ((2 << 20) / 10 + 1));

Please just use do_div here and go back to the first version of the
patch. Variable names could be more aligned with the RFC maybe?

> +	s32 v = cur * (u64)r >> 20;           /* ~ multiply by 1.9 .. 2.1 */
> +	if (v > ceiling) {
> +		r -= 1 << 20;
> +		v = ceiling * (u64)r >> 20;   /* ~ multiply by 0.9 .. 1.1 */
> +	}
> +	return v;
> +}

Thanks,
Hannes
