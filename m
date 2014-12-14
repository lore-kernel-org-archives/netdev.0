From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: correct the endianness of
 doorbell_qpn on big endian platform
Date: Sat, 13 Dec 2014 23:43:20 -0500 (EST)
Message-ID: <20141213.234320.1607496855879763694.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D1CA04A51@AcuExch.aculab.com>
	<20141208144237.GB8382@richard>
	<20141213031338.GA12208@richard>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, gideonn@mellanox.com, edumazet@google.com,
	amirv@mellanox.com
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbaLNEnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2014 23:43:23 -0500
In-Reply-To: <20141213031338.GA12208@richard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Sat, 13 Dec 2014 11:13:38 +0800

> On Mon, Dec 08, 2014 at 10:42:37PM +0800, Wei Yang wrote:
> If you prefer this way, I would like to send a new version for this.
> Is it ok for you?

I'm not so sure.  There are implications when using the __raw_*()
routines.

In particular, using __raw_{read,write}l() also means that the usual
necessary I/O memory barriers are not being performed.

There are therefore no ordering guarantees between __raw_*() and other
I/O or memory accesses whatsoever.
