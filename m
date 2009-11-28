From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] macvlan: support for guest vm direct rx/tx
Date: Fri, 27 Nov 2009 16:19:57 -0800 (PST)
Message-ID: <20091127.161957.243886653.davem@davemloft.net>
References: <20091113195201.11184.25766.stgit@mimic.site>
	<20091113132728.0f1db7c5@s6510>
	<200911280043.58784.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, pmullaney@novell.com, kaber@trash.net,
	netdev@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45017
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751586AbZK1ATj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 19:19:39 -0500
In-Reply-To: <200911280043.58784.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 28 Nov 2009 00:43:58 +0100

> On Friday 13 November 2009, Stephen Hemminger wrote:
>> Also, macvlan should really being calling netif_receive_skb()
>> not going through another queue/softirq cycle.
> 
> I've added a patch for this in my experimental queue now.
> When I last tried this, I saw a kernel stack overflow
> but it seems fine now.

I think it is unwise for any virtual device layer to use netif_receive_skb().
Just like tunnels they should always use netif_rx().

Otherwise stack overflow is a very real concern.
