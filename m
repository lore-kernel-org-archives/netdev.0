From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] pch_gbe: Fix transmit queue management
Date: Fri, 29 Nov 2013 16:42:29 -0500 (EST)
Message-ID: <20131129.164229.2292905485668904870.davem@davemloft.net>
References: <20131127.203929.1379316258754767343.davem@davemloft.net>
	<1385631882-12827-2-git-send-email-puzman@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: puzman@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752545Ab3K2Vmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:42:31 -0500
In-Reply-To: <1385631882-12827-2-git-send-email-puzman@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ondrej Puzman <puzman@gmail.com>
Date: Thu, 28 Nov 2013 10:44:39 +0100

> According to Documentation/networking/driver.txt the ndo_start_xmit method should not return NETDEV_TX_BUSY under normal circumstances.
> Stop the transmit queue when tx_ring is full.

Please format your commit message text to 80 columns.

> 
> Signed-off-by: Ondrej Puzman <puzman@gmail.com>

You should be instead preventing the transmit method from being invoked
when it might be possible that a request cannot be satisfied.

This means that at the end of a transmit request, you must stop the
queue if a packet with the maximum number of possible descriptors
cannot be satisfied.  Then it is impossible for the transmit function
to be invoked in a situation where it would need to fail for lack of
available transmit descriptors.

This is why drivers decided whether to stop their TX queues based upon
calculations involving MAX_SKB_FRAGS.
