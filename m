From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: fix potential race in vlan_cleanup_module vs vlan_ioctl_handler
Date: Tue, 11 Dec 2007 11:38:38 +0100
Message-ID: <475E68AE.6090708@trash.net>
References: <475E6587.1090306@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44076 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186AbXLKKik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 05:38:40 -0500
In-Reply-To: <475E6587.1090306@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> The vlan module cleanup function starts with
> 
> 	vlan_netlink_fini();
> 	vlan_ioctl_set(NULL);
> 
> The first call removes all the vlan devices and
> the second one closes the vlan ioctl.
> 
> AFAIS there's a tiny race window between these two
> calls - after rtnl unregistered all the vlans, but 
> the ioctl handler isn't set to NULL yet, user can 
> manage to call this ioctl and create one vlan device, 
> and that this function will later BUG_ON seeing 
> non-emply hashes.

Indeed, I can't see anything preventing this.

> I think, that we must first close the vlan ioctl
> and only after this remove all the vlans with the
> vlan_netlink_fini() call.

That looks correct, thanks Pavel. Dave, please apply.

