From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] smsc911x: protect INT_EN read-modify-write with
 spinlock
Date: Sun, 25 Jan 2009 17:47:36 -0800 (PST)
Message-ID: <20090125.174736.268120930.davem@davemloft.net>
References: <1232460114-13469-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38597
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751004AbZAZBre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 20:47:34 -0500
In-Reply-To: <1232460114-13469-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 20 Jan 2009 14:01:54 +0000

> This patch adds a new spinlock to protect read-modify-writes to the
> INT_EN register when enabling and disabling interrupt sources.
> 
> I haven't actually seen any devices lock up, but I think there's a
> possibility and I'd like to eliminate it.
> 
> Should I add this new spinlock, or should I extend the mac_lock
> to also cover these sections (renaming it to simply "lock")?
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

If you didn't have all of these RX multicast workaround
cases, things would be much easier.

The POLL and normal interrupt paths are already completely atomic for
you already.  And since POLL cannot happen until open() completes
that path would be safe too.

