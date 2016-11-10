From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5]] cadence: Add LSO support.
Date: Thu, 10 Nov 2016 12:01:23 -0500 (EST)
Message-ID: <20161110.120123.1915127624714352140.davem@davemloft.net>
References: <1478612463-15076-1-git-send-email-rafalo@cadence.com>
        <1478698862-12924-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: rafalo@cadence.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934425AbcKJRB2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 12:01:28 -0500
In-Reply-To: <1478698862-12924-1-git-send-email-rafalo@cadence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Wed, 9 Nov 2016 13:41:02 +0000

First, please remove the spurious closing bracket in your Subject line
in future submittions.

> +	if (is_udp) /* is_udp is only set when (is_lso) is checked */
> +		/* zero UDP checksum, not calculated by h/w for UFO */
> +		udp_hdr(skb)->check = 0;

This is really not ok.

If UFO is in use it should not silently disable UDP checksums.

If you cannot support UFO with proper checksumming, then you cannot
enable support for that feature.
