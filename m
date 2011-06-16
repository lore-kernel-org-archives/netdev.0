From: Jesper Juhl <jj@chaosbits.net>
Subject: rionet: NULL pointer dereference
Date: Fri, 17 Jun 2011 00:06:59 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1106162359560.8140@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Porter <mporter@kernel.crashing.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:15067 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422660Ab1FPWPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 18:15:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Just noticed that drivers/net/rionet.c::rionet_remove() can cause a NULL 
deref when it calls unregister_netdev().
It initializes local variable 'ndev' to NULL and nothing changes this 
before the call to unregister_netdev(ndev) - that functions then calls: 
unregister_netdevice > unregister_netdevice_queue > list_move_tail > 
__list_del_entry  which dereferences the pointer (which, being NULL, will 
end in tears).

I won't claim to know this code nor what the proper fix is; just thought 
i'd report it so someone else with more knowledge of this could perhaps 
come up with a fix.

Have a nice day.

-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.

