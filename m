From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] drivers/net/ni5010.c: fix compile error
Date: Wed, 21 Jun 2006 17:10:57 +0200
Message-ID: <20060621151057.GF9111@stusta.de>
References: <20060621034857.35cfe36f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:28422 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1751629AbWFUPK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 11:10:58 -0400
To: Andrew Morton <akpm@osdl.org>,
	Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Content-Disposition: inline
In-Reply-To: <20060621034857.35cfe36f.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 21, 2006 at 03:48:57AM -0700, Andrew Morton wrote:
>...
> Changes since 2.6.17-rc6-mm2:
>...
> +ni5010-netcard-cleanup.patch
> 
>  netdev cleanup
>...

This patch fixes the following compile error with CONFIG_NI5010=y:

<--  snip  -->

...
  LD      .tmp_vmlinux1
drivers/built-in.o:(.init.data+0x2b280): undefined reference to `ni5010_probe'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.17-mm1-full/drivers/net/ni5010.c.old	2006-06-21 16:21:26.000000000 +0200
+++ linux-2.6.17-mm1-full/drivers/net/ni5010.c	2006-06-21 16:21:46.000000000 +0200
@@ -117,7 +117,7 @@
 static int io;
 static int irq;
 
-static struct net_device * __init ni5010_probe(int unit)
+struct net_device * __init ni5010_probe(int unit)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct ni5010_local));
 	int *port;

