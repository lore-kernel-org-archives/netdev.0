From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Thu, 15 Nov 2007 20:04:31 -0800 (PST)
Message-ID: <20071115.200431.102331739.davem@davemloft.net>
References: <473D0482.4050705@cn.fujitsu.com>
	<20071115.185403.138420969.davem@davemloft.net>
	<473D0BF8.3060902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50997
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757356AbXKPEEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 23:04:32 -0500
In-Reply-To: <473D0BF8.3060902@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 16 Nov 2007 11:18:16 +0800

> Actually, I tested and found this issue.
> I sent 50 udp packets, which have wrong checksum, to my
> machine.
> Before the patch being applied, /proc/net/snmp's udp
> InDatagrams increased, and InErrors didn't increase.
> After the patch being applied, InErrors increased correctly
> and InDatagrams stayed unchanging.

That's right, InDataGrams will increase even if we haven't
verified the checksum yet.

When the user does a recvmsg() or a poll() on the socket,
we will notice the bad checksum then and increment InErrors.
We could in this case correct the InDatagrams counter by
decrementing it in this case.
