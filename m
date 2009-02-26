From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] igb: remove skb_orphan calls
Date: Thu, 26 Feb 2009 04:14:12 -0800 (PST)
Message-ID: <20090226.041412.18567576.davem@davemloft.net>
References: <20090226104621.10407.46879.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, mitch.a.williams@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48288
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752340AbZBZMOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 07:14:31 -0500
In-Reply-To: <20090226104621.10407.46879.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Feb 2009 02:46:23 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The skb_orphan call in the tx path has been shown to cause issues as seen
> with the workarounds required for timestamping.
> 
> In order to avoid this it is easiest just to remove the skb_orphan call as
> the motivation for including it was purely performance based, and the
> overall gain from having the call was minimal.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

While I'm happy to apply this, I don't see it as helping the
timestamping situation.

All someone has to do is enable the new timestamping on loopback to
trigger the problem, the loopback MUST orphan SKBs before it pushes
them back into the stack for receive.

Also, Herbert and I have talked about orphaning SKBs even earlier than
dev_queue_xmit()

This post-send timestamping scheme is not going to work, is poorly
designed, and needs to be completely rearchitected.

If it isn't fixed soon, I'll have no choice but to completely revert
all of the timestamping stuff.
