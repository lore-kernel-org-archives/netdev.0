From: David Miller <davem@davemloft.net>
Subject: Re: PATCH net-next-2.6] linkwatch: linkwatch_forget_dev() to
 speedup device dismantle
Date: Tue, 17 Nov 2009 04:26:04 -0800 (PST)
Message-ID: <20091117.042604.99618154.davem@davemloft.net>
References: <4B019381.2010509@gmail.com>
	<4B01C938.8000705@gmail.com>
	<20091116143917.14e4fa4f@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35478
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751839AbZKQMZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 07:25:48 -0500
In-Reply-To: <20091116143917.14e4fa4f@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 16 Nov 2009 14:39:17 -0800

> On Mon, 16 Nov 2009 22:50:48 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Is this really valid?

The whole point in emitting the netif_carrier_off() is so
that applications see the event in userspace and therefore
can clean things up.

Sure, the kernel will no longer make the device visible, and therefore
the application can't operate on it any longer.  But the application
is deserved of receiving the event anyways so that it can clean up
internal state and datastructures.

It seem to me that in this ->stop() case we'll now elide the event
emission, and I don't see how that can be right.

Really, the link watch stuff is just due for a redesign.  I don't
think a simple hack is going to cut it this time, sorry Eric :-)
