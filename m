From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: using AF_PACKET socket to send multicast packet
 cause WARNING
Date: Thu, 03 Apr 2014 12:48:23 -0400 (EDT)
Message-ID: <20140403.124823.898955109709979033.davem@davemloft.net>
References: <CADvbK_dK_fBB3bQSWKkAk6adtgrHm553Hr3JGHsw67qeS0cQOw@mail.gmail.com>
	<20140402075106.3eec7791@nehalam.linuxnetplumber.net>
	<CADvbK_ftDf_AsbEeF9EViBm68Co3bj1L-fR1-BDA0Uxn=1LPpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665AbaDCQqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 12:46:49 -0400
In-Reply-To: <CADvbK_ftDf_AsbEeF9EViBm68Co3bj1L-fR1-BDA0Uxn=1LPpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lucien xin <lucien.xin@gmail.com>
Date: Thu, 3 Apr 2014 13:28:33 +0800

> On Wed, Apr 2, 2014 at 10:51 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> That breaks local socket accounting for tunneled packets.
> It do break, I think it should break, becaue vlxan send UDP packets,
> it should be bound to UDP socket.

The issue is that we use sockets in two different contexts here:

1) For memory accounting, which is why we should hold onto the
   original socket.

2) For IP transmit state, which is why we need to reference the
   vxlan layer's ipv4/ipv6 socket.

Also, we've never marked the vxlan socket as being charged to
the SKB, there may be unwanted side effects of this.

Furthmore this will hurt performance, it will add two new
atomic operations per packet send over VXLAN devices.
