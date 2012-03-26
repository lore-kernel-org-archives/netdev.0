From: Erik Hugne <erik.hugne@ericsson.com>
Subject: [Question] Kernel preemption of BH handler
Date: Mon, 26 Mar 2012 11:20:43 +0200
Message-ID: <4F7034EB.8010707@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:43526 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754788Ab2CZJVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 05:21:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a BH handler that processes packets received from a netdevice.

my_bh_handler() {
   spin_lock_bh(my_lock);
   /*do stuff*/
   spin_unlock_bh(my_lock);
   /*do more stuff*/
}

First packet is received, and my_bh_handler() is currently processing it.
Now a new packet is received by the NIC and my_bh_handler() is preempted 
after my_lock have been released.

Is it possible that the second invocation of the BH routine is allowed 
to finish before the first?

//E
