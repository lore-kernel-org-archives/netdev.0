From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: account SYN-ACK timeouts & retransmissions
Date: Thu, 07 Jan 2010 17:25:07 -0800 (PST)
Message-ID: <20100107.172507.04893002.davem@davemloft.net>
References: <1262808658-29346-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpyatkovskiy@ixiacom.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34992
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751706Ab0AHBY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 20:24:59 -0500
In-Reply-To: <1262808658-29346-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed,  6 Jan 2010 22:10:58 +0200

> Signed-off-by: Maksim Pyatkovskiy <mpyatkovskiy@ixiacom.com>
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

RETRANSSEGS is meant to count data segments retransmits, not pure
control frames.

Similarly for TCPTIMEOUTS, it's mean for data retransmit timeouts.

If you overload these statistics with other similar events, they
become less meaningful.

Finally, bumping TCP specific statistics from the generic INET
connection oriented socket code is a huge no-no.  That code is
written to be protocol agnostic.
