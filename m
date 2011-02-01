From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Consolidate ipv4 default route selection
Date: Mon, 31 Jan 2011 16:25:42 -0800 (PST)
Message-ID: <20110131.162542.229747542.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752920Ab1BAAZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 19:25:07 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A85DB24C087
	for <netdev@vger.kernel.org>; Mon, 31 Jan 2011 16:25:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We've had two copies of this code for ages, and it has always driven
me crazy when I've seen these things.

With some minor changes, we can have one generic copy which is also
much more efficient than what we have right now.

Part of what makes this so easy to do right now is all of the RCU work
Eric has done in the FIB layers.  Since all of the datastructures are
RCU protected, and fib_select_default() already runs in an RCU read
side protected area, there is no special locking needed.
