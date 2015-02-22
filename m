From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/hsr: Fix NULL pointer dereference and refcnt
 bugs when deleting a HSR interface.
Date: Sat, 21 Feb 2015 20:17:49 -0500 (EST)
Message-ID: <20150221.201749.1670391333178699646.davem@davemloft.net>
References: <54E637FE.5030601@alten.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: arvid.brodin@alten.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbbBVBRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 20:17:53 -0500
In-Reply-To: <54E637FE.5030601@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@alten.se>
Date: Thu, 19 Feb 2015 20:22:38 +0100

> How to repeat:
> 
> $ sudo ip link add hsr0 type hsr slave1 <if1> slave2 <if2>
> $ sudo ip link del hsr0
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
> IP: [<ffffffff8187f495>] hsr_del_port+0x15/0xa0
> etc...
> 
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Fixes: 51f3c605318b056a ("net/hsr: Move slave init to hsr_slave.c.")
> Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>

You're going to have to write a better commit log message than
this.

For example, wouldn't it be better to restructure the code or
rearrange things slightly rather than just sticking NULL pointer
checks all over the place?

If this were structures properly, you wouldn't get notifications
for devices which lack a device private.

A spackling of NULL pointer checks to fix a bug is always a huge
red flag.
