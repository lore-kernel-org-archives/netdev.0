From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: surprising memory request
Date: Fri, 18 Jan 2013 09:54:33 -0800
Message-ID: <1358531673.11051.420.camel@edumazet-glaptop>
References: <20130118085818.147220.FMU5901@air.gr8dns.org>
	 <1358531190.11051.402.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>
To: Dirk Hohndel <dirk@hohndel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:62521 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754945Ab3ARRyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 12:54:35 -0500
Received: by mail-pa0-f51.google.com with SMTP id fb11so2248983pad.24
        for <netdev@vger.kernel.org>; Fri, 18 Jan 2013 09:54:35 -0800 (PST)
In-Reply-To: <1358531190.11051.402.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-18 at 09:46 -0800, Eric Dumazet wrote:

> Thats because Jason thought that tun device had to have an insane number
> of queues to get good performance.
> 
> #define MAX_TAP_QUEUES 1024
> 
> Thats crazy if your machine has say 8 cpus.
> 
> And Jason didnt care to adapt the memory allocations done in
> alloc_netdev_mqs(), in order to switch to vmalloc() when kmalloc()
> fails.

I suggest using the more reasonable :

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index c81680d..ec18fbf 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -113,7 +113,7 @@ struct tap_filter {
  * the order of 100-200 CPUs so this leaves us some breathing space if we want
  * to match a queue per guest CPU.
  */
-#define MAX_TAP_QUEUES 1024
+#define MAX_TAP_QUEUES DEFAULT_MAX_NUM_RSS_QUEUES
 
 #define TUN_FLOW_EXPIRE (3 * HZ)
 
