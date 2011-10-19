From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Disable LRO on FCoE or iSCSI boot
 device
Date: Wed, 19 Oct 2011 16:06:53 -0400 (EDT)
Message-ID: <20111019.160653.684945718064985511.davem@davemloft.net>
References: <1318563481-19631-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296Ab1JSUG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 16:06:57 -0400
In-Reply-To: <1318563481-19631-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 13 Oct 2011 20:38:01 -0700

> From: Dmitry Kravkov <dmitry@broadcom.com>
> 
> For an FCoE or iSCSI boot device, the networking side must stay "up" all
> the time.  Otherwise, the FCoE/iSCSI interface driven by bnx2i/bnx2fc
> will be reset and we'll lose the root file system.
> 
> If LRO is enabled, scripts that enable IP forwarding or bridging will
> disable LRO and cause the device to be reset.  Disabling LRO on these
> boot devices will prevent the reset.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

You're still going to have bugs after this.

What if you get a FIFO overflow or other error condition which requires
a chip reset?  You'll lose the root filesystem.  Why bother resetting
the chip at all if it's going to be useless afterwards?

The bug is in the fact that iSCSI context state isn't preserved or
reloaded across a chip reset.

Please fix that instead, and that way you won't have to add special
hacks for the root filesystem.  Everything will "just work'.
