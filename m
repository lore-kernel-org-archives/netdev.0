From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Thu, 26 Aug 2010 21:34:19 -0700 (PDT)
Message-ID: <20100826.213419.189712657.davem@davemloft.net>
References: <1282762851-3612-1-git-send-email-greearb@candelatech.com>
	<20100826.155915.200379485.davem@davemloft.net>
	<4C773BAF.7010809@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53190
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752941Ab0H0EeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 00:34:04 -0400
In-Reply-To: <4C773BAF.7010809@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 26 Aug 2010 21:14:39 -0700

> I'll look into the NET_XMIT_CN, but if that propagates backpressure up
> through mac-vlan, then something must know how to re-start the tx
> logic.

It doesn't need to, as it drops and frees up the packet.

> One thing that really bothers me about the current qdisc stuff is that
> it just frees the packet when it cannot accept it.

Without the drop, things like RED simply would not work.

> This *should* allow us to better throttle UDP sockets without
> dropping as many packets on the sending side, and would probably
> help TCP as well.

UDP is well throttled by the socket send buffer.

The only problematic case is pktgen and it's an abberation and
an obscure case.  It's in fact trying to bypass all of the
queueing and accounting the stack normally makes use of.
