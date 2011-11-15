From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: return NET_RX_DROP when arp_rcv drops the
 received packet.
Date: Tue, 15 Nov 2011 16:47:06 -0500 (EST)
Message-ID: <20111115.164706.1420496299997283498.davem@davemloft.net>
References: <1321322987-16042-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588Ab1KOVrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 16:47:08 -0500
In-Reply-To: <1321322987-16042-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Tue, 15 Nov 2011 10:09:47 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> return NET_RX_DROP when arp_rcv drops the received packet.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>

This is not appropriate.

NET_RX_DROP means that the packet was dropped because something about
the packet's contents were not acceptable, or the packet violated our
policies so was dropped.

In this arp_rcv() case, we would have accepted the packet, but we had
a memory allocation error.  This memory allocation error has nothing
to do with the packet's contents, and is a transient issue.
