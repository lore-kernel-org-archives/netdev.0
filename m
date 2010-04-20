From: David Miller <davem@davemloft.net>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 16:45:05 -0700 (PDT)
Message-ID: <20100420.164505.34362726.davem@davemloft.net>
References: <Pine.LNX.4.64.1004201834190.29017@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lists.linux-foundation.org@redhat.com, netdev@vger.kernel.org,
	kaber@trash.net
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49185
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753053Ab0DTXpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:45:00 -0400
In-Reply-To: <Pine.LNX.4.64.1004201834190.29017@hs20-bc2-1.build.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 20 Apr 2010 19:40:56 -0400 (EDT)

> Reviewing the code further, I found one very weird commit
> 572a9d7b6fc7f20f573664063324c086be310c42 committed to 2.6.33. What
> it does, it changes the semantics of ndo_hard_start_xmit(). Prior to
> the patch, the meaning was --- return zero (NETDEV_TX_OK) --- the
> skb is consumed by the driver. Returns non-zero --- the skb is left
> owned by the caller.  The patch changes it to return other flags in
> bits 4-7 and changes the consumed/returned logic.
> 
> The problem is that there is still plenty of code that compares it
> against NETDEV_TX_OK to find out if the skb was consumed.

Drivers are not supposed to return those new flag bits, the new flag
bits as return values exist only in the packet scheduler path.

We're not reverting the commit you mention, we're going to fix
whatever bug exists instead.
