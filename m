From: Vincent Bernat <bernat@luffy.cx>
Subject: Unequal balancing on bonds with links down
Date: Fri, 01 Feb 2013 16:20:36 +0100
Message-ID: <ee92daba1b8af8e3e2b743bcb0c4d25f@luffy.cx>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:47117 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140Ab3BAPUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 10:20:40 -0500
Received: from webmail.luffy.cx (conis.luffy.cx [10.116.129.5])
	by bart.luffy.cx (Postfix) with ESMTP id 2673F149A9
	for <netdev@vger.kernel.org>; Fri,  1 Feb 2013 16:20:36 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

When a bond has one of its members down, the balancing becomes unequal. 
For example, a four-member bond with the first member down, all the 
traffic that should have been sent to this first member is sent to the 
next one. This may be a lot of additional traffic for one interface. 
This applies for both balance-xor and balance-rr. For balance-xor, the 
hash could be computed modulo the number of active interfaces. For 
balance-rr, inactive interfaces could be skipped. Is there some reason 
that selection of TX interface is not done this way? If there is none, I 
may come with a patch for this.
