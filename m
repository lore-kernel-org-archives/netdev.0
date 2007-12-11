From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: fix potential race in vlan_cleanup_module vs
 vlan_ioctl_handler
Date: Tue, 11 Dec 2007 02:41:38 -0800 (PST)
Message-ID: <20071211.024138.123602914.davem@davemloft.net>
References: <475E6587.1090306@openvz.org>
	<475E68AE.6090708@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751785AbXLKKli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:41:38 -0500
In-Reply-To: <475E68AE.6090708@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 11 Dec 2007 11:38:38 +0100

> Pavel Emelyanov wrote:
> > AFAIS there's a tiny race window between these two
> > calls - after rtnl unregistered all the vlans, but 
> > the ioctl handler isn't set to NULL yet, user can 
> > manage to call this ioctl and create one vlan device, 
> > and that this function will later BUG_ON seeing 
> > non-emply hashes.
> 
> Indeed, I can't see anything preventing this.
> 
> > I think, that we must first close the vlan ioctl
> > and only after this remove all the vlans with the
> > vlan_netlink_fini() call.
> 
> That looks correct, thanks Pavel. Dave, please apply.

Applied to net-2.6, thanks!
