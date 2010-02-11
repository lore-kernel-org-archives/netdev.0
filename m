From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v4] tcp: fix ICMP-RTO war
Date: Wed, 10 Feb 2010 18:04:20 -0800 (PST)
Message-ID: <20100210.180420.149959191.davem@davemloft.net>
References: <4B7303C2.5000703@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36408
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753702Ab0BKCEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 21:04:05 -0500
In-Reply-To: <4B7303C2.5000703@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Wed, 10 Feb 2010 20:06:42 +0100

> Make sure, that TCP has a nonzero RTT estimation after three-way
> handshake. Currently, a listening TCP has a value of 0 for srtt,
> rttvar and rto right after the three-way handshake is completed
> with TCP timestamps disabled.
> This will lead to corrupt RTO recalculation and retransmission
> flood when RTO is recalculated on backoff reversion as introduced
> in "Revert RTO on ICMP destination unreachable"
> (f1ecd5d9e7366609d640ff4040304ea197fbc618).
> This behaviour can be provoked by connecting to a server which
> "responds first" (like SMTP) and rejecting every packet after
> the handshake with dest-unreachable, which will lead to softirq
> load on the server (up to 30% per socket in some tests).
> 
> Thanks to Ilpo Jarvinen for providing debug patches and to
> Denys Fedoryshchenko for reporting and testing.
> 
> Changes since v3: Removed bad characters in patchfile.
> 
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>

Applied, thank you very much for fixing this bug.
