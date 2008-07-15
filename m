From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/14]: Make packet scheduler multiqueue aware.
Date: Mon, 14 Jul 2008 18:48:49 -0700 (PDT)
Message-ID: <20080714.184849.121429019.davem@davemloft.net>
References: <20080714.155908.174564017.davem@davemloft.net>
	<487BEE7C.6080300@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45049
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754117AbYGOBss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 21:48:48 -0400
In-Reply-To: <487BEE7C.6080300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 15 Jul 2008 02:25:32 +0200

> Unfortunately that seems to imply that anything but the really
> simple qdiscs can't be used transparently in combination with
> multiqueue without breaking configurations.

I think we can fix this after the merge window :)

One idea is to allow all of the queues to point at a
single qdisc.  We'd just need to work out how to do the
locking.

For example, the Qdisc has a lock member, and a pointer.
For simple qdiscs the pointer points at the netdev_queue
lock.  But when sharing, we use the in-Qdisc static lock.
