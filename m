From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections
Date: Sat, 01 Nov 2008 21:15:41 -0700 (PDT)
Message-ID: <20081101.211541.182428064.davem@davemloft.net>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yavor@simplifymedia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750823AbYKBEQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:16:06 -0400
In-Reply-To: <241CE5A1B2AFFA4987A663380D74C0BB3FD69B08A7@MBX73.ad2.softcom.biz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yavor Goulishev <yavor@simplifymedia.com>
Date: Tue, 28 Oct 2008 17:06:33 -0400

> I'm sending you a tiny patch for the kernel.  The change allowed me
> to establish more than 64K outgoing TCP connections from a single
> Linux box.  Being able to use multihomed client box to load test a
> server reduced dramatically the number of physical boxes I needed.
> The other way to go was virtual machines, but you can't beat the
> simplicity of the single multihomed client.  Also the patch fixes an
> important symmetry.  Using the multihome setup is a simple technique
> to overcome the 64K limit on the server side.  The patch makes it
> possible on the client side too.
> 
> The fix is only for TCP but probably the same issue exists for UDP.
> I didn't had the time to investigate.
> 
> The patch is against the latest code base 2.6.28-rc2.

As I mentioned in my initial reply to you, this exact patch
has been proposed in the future and rejected.

The problem is that although it fixes the limitation, it
introduces a new problem.

The current code tries to keep the hash chains as shallow
as possible.  One part of how it achieves this is that it
tries to use up all the available ports using it's
scanning algorithm.  Your change works against this, and
will tend to make the hash chains deeper.

A solution needs to be devised which handles both issues.
