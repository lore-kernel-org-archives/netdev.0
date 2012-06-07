From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG, 3.4.1, l2tp, kernel panic on rmmod l2tp_eth
Date: Thu, 07 Jun 2012 11:12:26 +0200
Message-ID: <1339060346.26966.106.camel@edumazet-glaptop>
References: <61a2ca9cc47a9a9a1c8a36738090dbf9@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63691 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176Ab2FGJMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 05:12:31 -0400
Received: by eaak11 with SMTP id k11so126076eaa.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 02:12:30 -0700 (PDT)
In-Reply-To: <61a2ca9cc47a9a9a1c8a36738090dbf9@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-07 at 11:31 +0300, Denys Fedoryshchenko wrote:
> Hi
> 
> Sorry for weird looking message, but this is how i got it over 
> netconsole
> 
> If i have any tunnel+session configured and up and will do rmmod 
> l2tp_eth,
> i will get panic, after my userspace program will fetch interfaces 
> information (over netlink).
> 
> Probably it should not rmmod if there is tunnels configured?

Sure, can you try the following patch ?

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 443591d..185f12f 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -162,6 +162,7 @@ static void l2tp_eth_delete(struct l2tp_session *session)
 		if (dev) {
 			unregister_netdev(dev);
 			spriv->dev = NULL;
+			module_put(THIS_MODULE);
 		}
 	}
 }
@@ -249,6 +250,7 @@ static int l2tp_eth_create(struct net *net, u32 tunnel_id, u32 session_id, u32 p
 	if (rc < 0)
 		goto out_del_dev;
 
+	__module_get(THIS_MODULE);
 	/* Must be done after register_netdev() */
 	strlcpy(session->ifname, dev->name, IFNAMSIZ);
 
