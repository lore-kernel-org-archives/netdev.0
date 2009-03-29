From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/b44.c: fix regressions in error recovery
Date: Sun, 29 Mar 2009 13:48:13 -0700 (PDT)
Message-ID: <20090329.134813.151007211.davem@davemloft.net>
References: <Pine.LNX.4.64.0903291509460.8069@zem.cjw.nep>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cjw@daneel.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39231
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753721AbZC2UsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 16:48:25 -0400
In-Reply-To: <Pine.LNX.4.64.0903291509460.8069@zem.cjw.nep>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christiaan Welvaart <cjw@daneel.dyndns.org>
Date: Sun, 29 Mar 2009 15:25:16 +0200 (CEST)

> hi,
> 
> When I max out a b44 device using NFS and then add http traffic (both inbound), the device resets every few minutes. This causes huge delays due to the PHY reset which was introduced by commit http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=fedb0eefe286a6409aa2c6c6f2353c595e68d33d
> It changes b44_halt() to disable the PHY but this function gets called in 2 error recovery situations and some configuration changes. IMHO disabling the PHY in those cases is a total waste of time. This patch reverts those cases to the old behavior.
> 
> Signed-off-by: Christiaan Welvaart <cjw@daneel.dyndns.org>

Firstly your patch was corrupted by your email client,
lots of whitespace damange at the beginning of lines etc.

And I don't necessarily agree with your change.

If the chip TX times out, we have no idea really what caused
the problem otherwise it wouldn't happen in the first place.
So resetting the PHY is definitely an appropriate course of
action.

You really need to find out why the chip is crapping out in
the first place, and fix that, to get rid of the delays.
