From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/8] Simplify IPSEC lookup interfaces.
Date: Tue, 01 Mar 2011 15:11:19 -0800 (PST)
Message-ID: <20110301.151119.28805270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756985Ab1CAXKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:10:42 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id B1D9424C087
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 15:11:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We have two major uglies in our IPSEC rule resolution main entrypoint(s).

First, we have two interfaces, xfrm_lookup and __xfrm_lookup solely so
that callers can implement blackhole route resolution locally.  This
results in a lot of duplicated code.

But it's unnecessary as we can simply make this an afinfo->op()

Secondly we have all of this magic to propagate "can sleep in this
context" state via messy arguments.  Store this inside of the flow
flags instead of via extra arguments.

Now we are down to one interface, xfrm_lookup().

Signed-off-by: David S. Miller <davem@davemloft.net>
