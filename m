From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: xilinx_emaclite: fix receive buffer overflow
Date: Tue, 14 Feb 2017 15:12:59 -0500 (EST)
Message-ID: <20170214.151259.1157334352658192111.davem@davemloft.net>
References: <20170214171145.26953-1-anssi.hannula@bitwise.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
        netdev@vger.kernel.org
To: anssi.hannula@bitwise.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42162 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755082AbdBNUNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 15:13:06 -0500
In-Reply-To: <20170214171145.26953-1-anssi.hannula@bitwise.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anssi Hannula <anssi.hannula@bitwise.fi>
Date: Tue, 14 Feb 2017 19:11:44 +0200

> xilinx_emaclite looks at the received data to try to determine the
> Ethernet packet length but does not properly clamp it if
> proto_type == ETH_P_IP or 1500 < proto_type <= 1518, causing a buffer
> overflow and a panic via skb_panic() as the length exceeds the allocated
> skb size.
> 
> Fix those cases.
> 
> Also add an additional unconditional check with WARN_ON() at the end.
> 
> Signed-off-by: Anssi Hannula <anssi.hannula@bitwise.fi>
> Fixes: bb81b2ddfa19 ("net: add Xilinx emac lite device driver")

Why does this driver do all of this crazy stuff parsing the packet
headers?

It should be able to just read the length provided by the device
at XEL_RPLR_OFFSET and just use that.
