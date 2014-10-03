From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH 0/2] net: spider_net: fix possible bitops errors
Date: Fri,  3 Oct 2014 17:01:53 +0200
Message-ID: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: dan.carpenter@oracle.com, kou.ishizaki@toshiba.co.jp,
	jens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:46664 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752006AbaJCPB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:01:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Dan reported a possible signedness issue on the pxa168_eth driver. While
having a look at it, I came across a similar problem in the spider_net
driver.

Here is one proposal to fix it. The first patch rework the
spider_net_set_mac() function by removing the spider_net_get_mac_address()
call and using memcpy() to set netdev->dev_addr (which is what's done in
lots of Ethernet drivers) and the second one fix the actual signedness
issue.

If for any reason you really want to keep a call to
spider_net_get_mac_address() because the memcpy() is somehow not good
enough here, we can also come up with a solution involving a temporary
unsigned char variable.

I couldn't test these changes, so please do.

Thanks,

Antoine

Antoine Tenart (2):
  net: spider_net: do not read mac address again after setting it
  net: spider_net: avoid using signed char for bitops

 drivers/net/ethernet/toshiba/spider_net.c | 42 ++++---------------------------
 1 file changed, 5 insertions(+), 37 deletions(-)

-- 
1.9.1
