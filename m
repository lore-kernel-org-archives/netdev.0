From: Wang Jian <lark@linux.net.cn>
Subject: drivers/net/phy/marvell.c: 88e1111 can't get out sleep mode
Date: Mon, 29 Sep 2008 21:33:06 +0800
Message-ID: <20080929133305.GA10554@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Fleming <afleming@freescale.com>,
	Jeff Garzik <jeff@garzik.org>,
	Alexandr Smirnov <asmirnov@ru.mvista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [210.82.31.146] ([210.82.31.146]:35308 "EHLO mx.linux.net.cn"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753348AbYI2ONt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2008 10:13:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

During my testing, I found that 88e1111 can't get out of sleep mode
(Energy detect+) in certain condition.

I am working on a mpc8541 board, with TSEC (gianfar) connected to 88e1111
phy chip. The kenrel is 2.6.26-rc8 with several patches.

The following steps can 100% trigger the problem

1. unplug cable from tsec interfaces (eth0/eth1 in my case)
2. boot up and waiting for 6+ seconds
3. ifconfig eth0 up
4. plug in cable, the link can't be established and no way to bring it
   up

But these steps can make link up

1. boot up with cable plugged or plug the cable in 6 seconds after
   bootup
2. unplug cable
3. ifconfig eth0 up
4. plugin in cable, the link is up

I tried some workarounds and no success. so far I get these information

1. When cable plugged before ifconfig eth0 up and in the 6 seconds window,
   the bit 11 of register 17, "speed and duplex resolved" is true even 
   unplug cable later
2. auto negotination enable bit (bit 12 of BMCR) is true in both cases

Can someone help me to confirm this problem? I can provide more
information/prink output per request.

Note: I have these two patches applied (in current linus tree)

commit 7239016d52c6d568d069f083bdcd17f35ab79fd8
Author: Wang Jian <lark@linux.net.cn>
Date:   Wed Jul 16 21:46:20 2008 +0800

commit 9cf8fa4334e60f27b4a392f432c292f3af268215
Author: Wang Jian <lark@linux.net.cn>
Date:   Wed Jul 16 21:46:17 2008 +0800
