From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: Fix use after free of struct macvlan_port.
Date: Mon, 21 Mar 2011 18:22:32 -0700 (PDT)
Message-ID: <20110321.182232.200375244.davem@davemloft.net>
References: <m1aagojhu4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, greearb@candelatech.com,
	eric.dumazet@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41647
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755028Ab1CVBVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 21:21:54 -0400
In-Reply-To: <m1aagojhu4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 21 Mar 2011 14:15:31 -0700

> 
> When the macvlan driver was extended to call unregisgter_netdevice_queue
> in 23289a37e2b127dfc4de1313fba15bb4c9f0cd5b, a use after free of struct
> macvlan_port was introduced.  The code in dellink relied on unregister_netdevice
> actually unregistering the net device so it would be safe to free macvlan_port.
> 
> Since unregister_netdevice_queue can just queue up the unregister instead of
> performing the unregiser immediately we free the macvlan_port too soon and
> then the code in macvlan_stop removes the macaddress for the set of macaddress
> to listen for and uses memory that has already been freed.
> 
> To fix this add a reference count to track when it is safe to free the macvlan_port
> and move the call of macvlan_port_destroy into macvlan_uninit which is guaranteed
> to be called after the final macvlan_port_close.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>

Applied, thanks Eric.
