From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/12 net-2.6.26] [NETNS]: icmp(v6)_sk should not pin a
 namespace.
Date: Fri, 29 Feb 2008 11:35:25 -0800 (PST)
Message-ID: <20080229.113525.108898422.davem@davemloft.net>
References: <1204292360.10368.11.camel@iris.sw.ru>
	<1204292458-11636-9-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44958
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754978AbYB2TfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:35:25 -0500
In-Reply-To: <1204292458-11636-9-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 29 Feb 2008 16:40:55 +0300

> So, change icmp(v6)_sk creation/disposal to the scheme used in the netlink
> for rtnl, i.e. create a socket in the context of the init_net and
> assign the namespace without getting a referrence later.
> 
> Also use sk_release_kernel instead of sock_release to properly destroy
> such sockets.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Please validate the build in the future, thanks :-/

I just checked in the following:

commit 45af1754bc09926b5e062bda24f789d7b320939f
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Feb 29 11:33:19 2008 -0800

    [NET]: sk_release_kernel needs to be exported to modules
    
    Fixes:
    
    ERROR: "sk_release_kernel" [net/ipv6/ipv6.ko] undefined!
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/sock.c b/net/core/sock.c
index c71b645..0ca0697 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1004,6 +1004,7 @@ void sk_release_kernel(struct sock *sk)
 	sk->sk_net = get_net(&init_net);
 	sock_put(sk);
 }
+EXPORT_SYMBOL(sk_release_kernel);
 
 struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 {
