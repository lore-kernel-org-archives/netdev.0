From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/7]: Fix napi_disable() wedge during packet flood.
Date: Mon, 07 Jan 2008 21:37:28 -0800 (PST)
Message-ID: <20080107.213728.07020820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50925
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750715AbYAHFh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:37:28 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 62807C8C217
	for <netdev@vger.kernel.org>; Mon,  7 Jan 2008 21:37:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


After going back and forth several times on how to fix this bug I
finally think I have a clean solution.

It is possible to clean up a ton of stuff, such as getting rid of
netif_rx_schedule() et al. (none of these interfaces care about the
netdev arg any long) but we should do that post 2.6.24 and just do
what is necessary to fix this bug first.

To the Intel driver maintainers, I know the last patch is contentious.
But at this time it is more important to have all of these drivers
behaving consistently.  If you want to have the TX work factor into
the ->poll() logic that is fine but please discuss it with the list
and apply that change consistently over all of the 5 drivers.  The
current situation was a bit of a mess.
