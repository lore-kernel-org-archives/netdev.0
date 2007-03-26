From: Paul Mackerras <paulus@samba.org>
Subject: Re: [irda-users] [2.6.20-rt8] "Neighbour table overflow."
Date: Mon, 26 Mar 2007 11:02:22 +1000
Message-ID: <17927.7070.803210.600520@cargo.ozlabs.ibm.com>
References: <FuqKSqqx.1174476366.8345250.samuel@sortiz.org>
	<Pine.LNX.4.63.0703211235220.534@pcgl.dsa-ac.de>
	<Pine.LNX.4.63.0703231309170.534@pcgl.dsa-ac.de>
	<20070324.221034.45741983.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gl@dsa-ac.de, samuel@sortiz.org, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36648 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933290AbXCZBCb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2007 21:02:31 -0400
In-Reply-To: <20070324.221034.45741983.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller writes:

> The PPP generic layer seems to be very careful about it's handling of
> the ->xmit_pending packet.

Mostly, but I think that this is a genuine leak.

> I'm really surprised this leak doesn't trigger already via the
> ppp_synctty.c and ppp_async.c drivers, perhaps they do something to
> make sure the transmitter gets purged properly when unregistering and
> therefore ->xmit_pending does not get left non-NULL at unregister
> time.

At least for ppp_async, I think what saves us is that pppd does a
TCFLSH ioctl when shutting down the link, which calls
ppp_async_flush_output, which calls ppp_output_wakeup.

Paul.
