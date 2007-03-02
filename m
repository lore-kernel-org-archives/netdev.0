From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 8107] New: dev->header_cache_update has a
 random value
Date: Thu, 01 Mar 2007 17:38:43 -0800 (PST)
Message-ID: <20070301.173843.104646614.davem@davemloft.net>
References: <20070301143727.4ba00d04@freekitty>
	<20070301145423.6ffc52e5.akpm@linux-foundation.org>
	<20070301153025.6559a53e@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, loveminix@yahoo.com.cn,
	khc@pm.waw.pl
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49566
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1422706AbXCBBip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 20:38:45 -0500
In-Reply-To: <20070301153025.6559a53e@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 1 Mar 2007 15:30:25 -0800

> Your right, but so far there is no ioctl to take it out of this mode.
> So it is a one way door.

You can keep attaching a different new protocol to an HDLC
device until it is brought up.

> This device never calls hdlc->detach??

The HDLC layer calls the protocol ->detach, but the Cisco
HDLC code does not have a detach method.

I'm starting to feel that this is the bug, because as it
stands the Cisco HDLC code leaves stale pointers around
and then if you unload the Cisco HDLC module things can
explode.
