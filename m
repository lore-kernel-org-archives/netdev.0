From: David Miller <davem@davemloft.net>
Subject: Re: netif_poll_enable() & barrier
Date: Thu, 28 Dec 2006 21:09:56 -0800 (PST)
Message-ID: <20061228.210956.85409699.davem@davemloft.net>
References: <1166586252.19254.118.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56566
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932655AbWL2FJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Dec 2006 00:09:56 -0500
To: benh@au1.ibm.com
In-Reply-To: <1166586252.19254.118.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Date: Wed, 20 Dec 2006 14:44:12 +1100

> I stumbled accross what might be a bug on out of order architecture:
> 
> netif_poll_enable() only does a clear_bit(). However,
> netif_poll_disable/enable pairs are often used as simili-spinlocks.
> 
> (netif_poll_enable() has pretty much spin_lock semantics except that it
> schedules instead of looping).
> 
> Thus, shouldn't netif_poll_disable() do an smp_wmb(); before clearing
> the bit to make sure that any stores done within the poll-disabled
> section are properly visible to the rest of the system before clearing
> the bit ?

Although I couldn't find a problematic case with any current
in-tree drivers, it's better to be safe than sorry :-)

So I'll add a smp_mb__before_clear_bit() to netif_poll_enable() :)
