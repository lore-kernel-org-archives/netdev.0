From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] [POWERPC] Fix fs_enet module build
Date: Mon, 05 Nov 2007 10:19:36 -0600
Message-ID: <472F4298.60005@freescale.com>
References: <472CDE02.1020804@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-embedded@ozlabs.org" <linuxppc-embedded@ozlabs.org>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>
To: Jochen Friedrich <jochen@scram.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:36484 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbXKEQTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 11:19:52 -0500
In-Reply-To: <472CDE02.1020804@scram.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jochen Friedrich wrote:
> diff --git a/drivers/net/fs_enet/Makefile b/drivers/net/fs_enet/Makefile
> index 02d4dc1..2f7563a 100644
> --- a/drivers/net/fs_enet/Makefile
> +++ b/drivers/net/fs_enet/Makefile
> @@ -4,7 +4,15 @@
> 
> obj-$(CONFIG_FS_ENET) += fs_enet.o
> 
> -obj-$(CONFIG_8xx) += mac-fec.o mac-scc.o mii-fec.o
> -obj-$(CONFIG_CPM2) += mac-fcc.o mii-bitbang.o
> +fs_enet-$(CONFIG_8xx) += mac-fec.o mac-scc.o
> +fs_enet-$(CONFIG_CPM2) += mac-fcc.o
> +
> +ifeq ($(CONFIG_8xx),y)
> +        obj-$(CONFIG_FS_ENET) += mii-fec.o
> +endif
> +
> +ifeq ($(CONFIG_CPM2),y)
> +        obj-$(CONFIG_FS_ENET) += mii-bitbang.o
> +endif
> 
> fs_enet-objs := fs_enet-main.o

If we're going to mess with this, we should probably just make 
CONFIG_FS_ENET_SCC, CONFIG_FS_ENET_FCC, and CONFIG_FS_ENET_FEC, and have 
them depend on CONFIG_FS_ENET.

-Scott
