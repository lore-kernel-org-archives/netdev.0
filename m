From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/2] Documentation:
 sysfs-class-net-statistics: Clarify rx_bytes and tx_bytes
Date: Thu, 25 May 2017 12:43:05 -0400 (EDT)
Message-ID: <20170525.124305.764605105083674654.davem@davemloft.net>
References: <1495573858-32346-1-git-send-email-andrew@lunn.ch>
        <1495573858-32346-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, hayeswang@realtek.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59096 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751861AbdEYQnH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:43:07 -0400
In-Reply-To: <1495573858-32346-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 23 May 2017 23:10:57 +0200

> Document what is expected for the rx_bytes and tx_bytes statistics in
> /sys/class/net/<device>/statistics. The FCS should be included in the
> statistics. However, since this has been unclear until now, it is
> expected a number of drivers don't. But maybe with time they will.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Precedence has not been very kind to us here.

Also, we really I want drivers doing the simplest thing possible,
which on transmit is:

	tx_bytes += skb->len;

Not:

	tx_bytes += skb->len + ETH_FCS_LEN;

I understand the problem you're trying to tackle, but software stats
should be for software state, and that state is emphatically skb->len

So if we are to strive for software statistic "consistency" it should
be against the software part of the packet, not the software part
"plus X and Y link layer stuff no visible in the software packet".

Thanks.
