From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][MIPS][7/7] AR7: ethernet
Date: Sat, 29 Sep 2007 01:39:19 -0400
Message-ID: <46FDE507.90206@pobox.com>
References: <200709201728.10866.technoboy85@gmail.com> <200709201813.48408.technoboy85@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, Eugene Konev <ejka@imfi.kspu.ru>,
	netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@coreworks.de, Andrew Morton <akpm@linux-foundation.org>
To: Matteo Croce <technoboy85@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39752 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750882AbXI2Fje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 01:39:34 -0400
In-Reply-To: <200709201813.48408.technoboy85@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Overall, looks pretty clean, good job!

Comments:

1) [major issue] Don't take and release a heavy lock on every single RX 
packet.

2) remove net_device_stats from private structure, and use net_device::stats

3) rx_ring_size should not be a module param, since that should be 
supported via ethtool

4) cpmac_tx_timeout() doesn't really do anything to alleviate the condition

5) don't set dev->mem_start and dev->mem_end, those are fields that are 
going away, and that's not their intended purpose.  just store a pointer 
to the resource info.


