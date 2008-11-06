From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: Don't leak packets when a netns is going down
Date: Wed, 05 Nov 2008 16:00:54 -0800 (PST)
Message-ID: <20081105.160054.261042048.davem@davemloft.net>
References: <m14p2l4v2l.fsf_-_@frodo.ebiederm.org>
	<m1y6zx3gcs.fsf_-_@frodo.ebiederm.org>
	<m1skq53g9l.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, containers@lists.osdl.org, den@openvz.org,
	xemul@openvz.org, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752660AbYKFABU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 19:01:20 -0500
In-Reply-To: <m1skq53g9l.fsf_-_@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 05 Nov 2008 15:27:34 -0800

> 
> I have been tracking for a while a case where when the
> network namespace exits the cleanup gets stck in an
> endless precessess of:
> 
> unregister_netdevice: waiting for lo to become free. Usage count = 3
> unregister_netdevice: waiting for lo to become free. Usage count = 3
> unregister_netdevice: waiting for lo to become free. Usage count = 3
> unregister_netdevice: waiting for lo to become free. Usage count = 3
> unregister_netdevice: waiting for lo to become free. Usage count = 3
> unregister_netdevice: waiting for lo to become free. Usage count = 3
> unregister_netdevice: waiting for lo to become free. Usage count = 3
> 
> It turns out that if you listen on a multicast address an unsubscribe
> packet is sent when the network device goes down.   If you shutdown
> the network namespace without carefully cleaning up this can trigger
> the unsubscribe packet to be sent over the loopback interface while
> the network namespace is going down.
> 
> All of which is fine except when we drop the packet and forget to
> free it leaking the skb and the dst entry attached to.  As it
> turns out the dst entry hold a reference to the idev which holds
> the dev and keeps everything from being cleaned up.  Yuck!
> 
> By fixing my earlier thinko and add the needed kfree_skb and everything
> cleans up beautifully. 
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.
