From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Fri, 31 Aug 2007 15:39:21 -0700
Message-ID: <1188599961.6062.198.camel@localhost>
References: <1188250006.18004.144.camel@localhost>
	 <20070827.143724.38316150.davem@davemloft.net>
	 <1188335521.6062.56.camel@localhost>
	 <20070828.142216.99461544.davem@davemloft.net>
	 <1188598563.6062.191.camel@localhost>
	 <1188598880.7585.52.camel@johannes.berg>
	 <1188599040.6062.192.camel@localhost>
	 <1188599575.7585.62.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1858 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754742AbXHaWj5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 18:39:57 -0400
In-Reply-To: <1188599575.7585.62.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-09-01 at 00:32 +0200, Johannes Berg wrote:
> I think you got a bit too trigger-happy:
>         p += sprintf(p, "key[%d] alg=CCMP key_set=%d "
> -                    "tx_pn=%02x%02x%02x%02x%02x%02x "
> -                    "rx_pn=%02x%02x%02x%02x%02x%02x "
> +                    "tx_pn=%s "
> +                    "rx_pn=%s "
>                      "format_errors=%d replays=%d decrypt_errors=%d\n",
>                      ccmp->key_idx, ccmp->key_set,
> -                    MAC_ARG(ccmp->tx_pn), MAC_ARG(ccmp->rx_pn),
> +                    print_mac(mac, ccmp->tx_pn), print_mac(mac2, ccmp->rx_pn),
> 
> the PN is a number, not a MAC address :) The fact that it used MAC_ARG,
> was, I guess, just laziness of the original author since the PN is also
> 6 bytes long. That said, I can live with it being printed this way too,
> it's just a bit weird.

Yes, that was one of the dodgy ones.
I didn't actually realize it wasn't a MAC address though.

I think all of the sprintf/seq_foo changes should be inspected.
I broke ipv6 once doing something similar to v6 addresses.

> Going to be fun to merge with my 70 outstanding patches though :)

That's a cheery definition of fun.

