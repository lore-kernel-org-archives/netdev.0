From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: b44: regression in 2.6.22
Date: Fri, 25 May 2007 17:24:31 -0700
Message-ID: <20070525172431.60affaca@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:51249 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753365AbXEZA3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 May 2007 20:29:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Something is broken with the b44 driver in 2.6.22-rc1 or later. Now bisecting.
The performance (with iperf) for receiving is normally 94Mbits or more.
But something happened that dropped performance to less than 1Mbit,
probably corrupted packets.

There is nothing obvious in the commit log for drivers/net/b44.c, so it
probably is something more general.


Looking at the code in b44_rx(), I see a couple unrelated of bugs:
1. In the small packet case it recycles the skb before copying data out... 
   Not good if new data arrives overwriting existing data.

2. Macros like RX_PKT_BUF_SZ that depend on local variables are evil!!



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
