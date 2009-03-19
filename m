From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: reset last known duplex and carrier on open
Date: Wed, 18 Mar 2009 23:38:07 -0700 (PDT)
Message-ID: <20090318.233807.31615311.davem@davemloft.net>
References: <1237313199-18617-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34650
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751715AbZCSGiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 02:38:20 -0400
In-Reply-To: <1237313199-18617-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 17 Mar 2009 18:06:39 +0000

> smsc911x_phy_adjust_link is called periodically by the phy layer (as
> it's run in polling mode), and it only updates the hardware when it sees
> a change in duplex or carrier.  This patch clears the last known values
> every time the interface is brought up, instead of only when the module
> is loaded.
> 
> Without this patch the adjust_link function never updates the hardware
> after an ifconfig down; ifconfig up.  On a full duplex link this causes
> the tx error counter to increment, even though packets are correctly
> transmitted, as the default MAC_CR register setting is for half duplex.
> 
> The tx errors are "no carrier" errors, which should be ignored in
> full-duplex mode.  When MAC_CR is set to "full duplex" mode they are
> correctly ignored by the hardware.
> 
> Note that even with this patch the tx error counter can increment if
> packets are transmitted between "ifconfig up" and the first phy poll
> interval.  An improved solution would use the phy interrupt with phylib,
> but I haven't managed to make this work 100% robustly yet.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Patch applied, thanks Steve.

If only other driver maintainers wrote as nice commit log
messages as you do, these days I'm lucky if I get a coherent
header line. :-/

