From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: fix bogus cast in skb_pagelen() and use unsigned
 variables
Date: Wed, 23 Nov 2016 12:49:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02265B3@AcuExch.aculab.com>
References: <20161119010808.GF1200@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alexey Dobriyan' <adobriyan@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.188]:60709 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936202AbcKWMtq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 07:49:46 -0500
In-Reply-To: <20161119010808.GF1200@avx2>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan
> Sent: 19 November 2016 01:08
...
> -	for (i = (int)skb_shinfo(skb)->nr_frags - 1; i >= 0; i--)
> +	for (i = skb_shinfo(skb)->nr_frags - 1; (int)i >= 0; i--)
>  		len += skb_frag_size(&skb_shinfo(skb)->frags[i]);

Think I'd use:
	for (i = skb_shinfo(skb)->nr_frags; i-- != 0; )

	David
