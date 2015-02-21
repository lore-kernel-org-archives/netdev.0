From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: Eliminate txhash in sock and reflect RX
 hash on transmit
Date: Fri, 20 Feb 2015 17:36:01 -0800
Message-ID: <1424482561.5565.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424478270-24783-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:44258 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754616AbbBUBgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 20:36:03 -0500
Received: by iecar1 with SMTP id ar1so12069939iec.11
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 17:36:02 -0800 (PST)
In-Reply-To: <1424478270-24783-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-20 at 16:24 -0800, Tom Herbert wrote:
> Instead of having a separate hash value in sock structure for transmit
> and receive, we can use the rxhash value for both and eliminate the
> txhash value. This simplifies the code and reflects the receive hash a
> device provides to the stack for packets transmitted on the associated
> connection. The hash value returned by a device could have meaning when
> used in transmit to identify a flow, for instance the hash may be a flow
> key for a flow created in a (virtual) device. With the flow key provided
> on transmit this can obviate the need to create the hash and do the
> lookup on the fly in transmit.

> +static inline void sock_init_rxhash(struct sock *sk)
> +{
> +	get_random_bytes(&sk->sk_rxhash, sizeof(u32));
>  }


Wow. You just depleted entropy pool completely.

prandom_bytes() or prandom_u32() will just be fine.

Quite frankly, all these changes seem pointless, as you have no
guarantee same hash will be used for packets of a given flow.

Obviously the outgoing SYN packet has no easy way to know what will be
the rxhash in opposite direction. I think I already mentioned this
problem.

So whats the point ?
