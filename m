From: Michael Buesch <mb@bu3sch.de>
Subject: wireless: NETDEV_TX_LOCKED, use it or not?
Date: Sat, 19 Aug 2006 12:22:42 +0200
Message-ID: <200608191222.42899.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:51937
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751699AbWHSKXr
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Aug 2006 06:23:47 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am currently wondering, if we should use NETDEV_TX_LOCKED
in the bcm43xx wireless net driver.

I currently don't have an SMP machine with a bcm43xx card
running, so I can't use benchmarks to find out.

There are various things to consider:
* The RX and TX-status paths, which also must take the spinlock
  aren't more expensive than on a normal Ethernet card (at least
  with d80211 stack).
* But the retry-path, when a NETDEV_TX_LOCKED is returned is
  slightly more expensive.

Well, the question is: Is it worth to return NETDEV_TX_LOCKED
on spinlock contention, or is it better to spin?
Is NETDEV_TX_LOCKED only desired on gigabit ethernet?

Thanks.

-- 
Greetings Michael.
