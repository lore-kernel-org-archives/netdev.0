From: David Miller <davem@davemloft.net>
Subject: Re: TCP timewait recycle/reuse for IPv6?
Date: Mon, 17 Mar 2008 12:10:06 -0700 (PDT)
Message-ID: <20080317.121006.206760103.davem@davemloft.net>
References: <200803171818.17494.opurdila@ixiacom.com>
	<47DEADC1.1040908@hp.com>
	<200803172004.33246.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50639
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752309AbYCQTJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:09:56 -0400
In-Reply-To: <200803172004.33246.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Mon, 17 Mar 2008 20:04:33 +0200

> While running the same traffic with IPv4, the timewait recyle/reuse
> features kicks in and keeps the number of TIMEWAIT sockets to under
> a 1000.

Timewait recycling should not be enabled if any of your connections
could even potentially be going through a firewall or NAT box.
In such cases, the invariants which are necessary for timewait
recycling to be valid are not present and thus you could risk
connection or data corruption.

Timewait recycling depends upon end systems really being end
systems on a connection level.  With NAT, that is no longer
true, as the NAT box will reuse the same port for different
end nodes in subsequent connections.
