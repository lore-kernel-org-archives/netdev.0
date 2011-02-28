From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: handle errors from netlink_dump()
Date: Mon, 28 Feb 2011 12:18:56 -0800 (PST)
Message-ID: <20110228.121856.39187061.davem@davemloft.net>
References: <1298292047-25025-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43318
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755164Ab1B1UST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:18:19 -0500
In-Reply-To: <1298292047-25025-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@openvz.org>
Date: Mon, 21 Feb 2011 15:40:47 +0300

> netlink_dump() may failed, but nobody handle its error.
> It generates output data, when a previous portion has been returned to
> user space. This mechanism works when all data isn't go in skb. If we
> enter in netlink_recvmsg() and skb is absent in the recv queue, the
> netlink_dump() will not been executed. So if netlink_dump() is failed
> one time, the new data never appear and the reader will sleep forever.
> 
> netlink_dump() is called from two places:
> 
> 1. from netlink_sendmsg->...->netlink_dump_start().
>    In this place we can report error directly and it will be returned
>    by sendmsg().
> 
> 2. from netlink_recvmsg
>    There we can't report error directly, because we have a portion of
>    valid output data and call netlink_dump() for prepare the next portion.
>    If netlink_dump() is failed, the socket will be mark as error and the
>    next recvmsg will be failed.
> 
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

This issue has existed since the very creation of the netlink code :-)

Applied, thanks!
