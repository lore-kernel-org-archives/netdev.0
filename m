From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] L2TP: Fix potential memory corruption in
 pppol2tp_recvmsg()
Date: Tue, 10 Jun 2008 12:36:12 -0700 (PDT)
Message-ID: <20080610.123612.162337098.davem@davemloft.net>
References: <200806101234.m5ACYOI4004732@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilja@netric.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45588
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753409AbYFJTgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:36:12 -0400
In-Reply-To: <200806101234.m5ACYOI4004732@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue, 10 Jun 2008 13:34:24 +0100

> This patch fixes a potential memory corruption in
> pppol2tp_recvmsg(). If skb->len is bigger than the caller's buffer
> length, memcpy_toiovec() will go into unintialized data on the kernel
> heap, interpret it as an iovec and start modifying memory.
> 
> The fix is to change the memcpy_toiovec() call to
> skb_copy_datagram_iovec() so that paged packets (rare for PPPOL2TP)
> are handled properly. Also check that the caller's buffer is big
> enough for the data and set the MSG_TRUNC flag if it is not so.
> 
> Reported-by: Ilja <ilja@netric.org>
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied, thanks.

Please see:

http://marc.info/?l=linux-netdev&m=121262022428660&w=2

for a description of how I would like folks to format their
commit header lines for networking changes nowadays.  I fixed
it up by hand for you this time.

> A candidate for -stable?

Yes, and I've queued it up for such.
