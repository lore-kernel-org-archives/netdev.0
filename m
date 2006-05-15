From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: ixp2000: handle enp2611s with two gigabit ports
Date: Mon, 15 May 2006 12:26:13 -0700
Message-ID: <20060515122613.6f10eb3e@localhost.localdomain>
References: <20060426222411.GA9882@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51351 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751442AbWEOT1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 15:27:40 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060426222411.GA9882@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Apr 2006 00:24:11 +0200
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> The ixp2000 driver for the enp2611 was developed on a board with
> three gigabit ports, but some enp2611 models only have two ports
> (and only one onboard PM3386.)  The current driver assumes there
> are always three ports and so it doesn't work on the two-port
> version of the board at all.
> 
> This patch adds a bit of logic to the enp2611 driver to limit the
> number of ports to 2 if the second PM3386 isn't detected.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

This patch got mangled, that is probably why jeff didn't apply it before
he left. I had to fix it manually.

patching file drivers/net/ixp2000/enp2611.c
patch: **** malformed patch at line 106:
module_init(enp2611_init_module);

In this part...

@@ -236,8 +240,10 @@
 	del_timer_sync(&link_check_timer);
 
 	ixpdev_deinit();
-	for (i = 0; i < 3; i++)
-		free_netdev(nds[i]);
+	for (i = 0; i < 3; i++) {
+		if (nds[i] != NULL)
			free_netdev(nds[i]);
+	}
 }
 
 module_init(enp2611_init_module);
