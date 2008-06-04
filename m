From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: DCB generic netlink interface
Date: Wed, 04 Jun 2008 11:44:56 -0700 (PDT)
Message-ID: <20080604.114456.32717312.davem@davemloft.net>
References: <20080527141339.12851.98781.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42051
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756640AbYFDSo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 14:44:57 -0400
In-Reply-To: <20080527141339.12851.98781.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Date: Tue, 27 May 2008 07:13:39 -0700

> This patchset adds the initial DCB generic netlink interface to the kernel.
> It adds the layer as a generic interface for any DCB-capable device through
> the netdevice.
> 
> This patchset also includes an implementation using this interface in the
> ixgbe driver.  It adds the hardware-specific code to turn the interface on,
> and includes the netlink callbacks in the driver to perform the requested
> operations.
> 
> These patches are targeted at the net-next-2.6 tree, for 2.6.27.  The patch
> series is as follows:
> 
> patch 1: DCB netlink interface in-kernel
> patch 2: ixgbe DCB hardware-specific patches
> patch 3: enable DCB in ixgbe

Overall the changes look OK.  In particular the netlink implementation
looks clean.

However we need to think about how this stuff overlaps with existing
'tc' facilities.  For example, what we really need to do here is
define this generic DCB interface such that it normally just sits on
top of a software scheduler layer implementation and therefore there
are always non-NULL DCB ops to invoke.

If there is a device that can implement this in hardware, that's
fine and we define some interface for invoking that.

Because of that, the netdevice is likely not the correct place for the
ops (the only actual ugly part of the patches in my opinion).

I'm still very active travelling which is why I haven't responded to
this earlier.  I ask that you express some understanding about this as
there is really nothing I can do to review these kinds of important
changes properly when I am changing 10 timezones every other day.

Besides we're still in bug fix phase, so nothing I say will get this
upstream into Linus's tree any faster, and we really need to get
something like this right because it will be hard to undo this
afterwards if we get it wrong.
