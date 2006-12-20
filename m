From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Subject: netif_poll_enable() & barrier
Date: Wed, 20 Dec 2006 14:44:12 +1100
Message-ID: <1166586252.19254.118.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:34761 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964861AbWLTDqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 22:46:02 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi !

I stumbled accross what might be a bug on out of order architecture:

netif_poll_enable() only does a clear_bit(). However,
netif_poll_disable/enable pairs are often used as simili-spinlocks.

(netif_poll_enable() has pretty much spin_lock semantics except that it
schedules instead of looping).

Thus, shouldn't netif_poll_disable() do an smp_wmb(); before clearing
the bit to make sure that any stores done within the poll-disabled
section are properly visible to the rest of the system before clearing
the bit ?

Cheers,
Ben.


