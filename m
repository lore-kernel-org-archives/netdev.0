From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Linker error on via-velocity driver
Date: Tue, 22 Aug 2006 00:07:35 +0200
Message-ID: <20060821220735.GA12622@electric-eye.fr.zoreil.com>
References: <44EA14BF.5090102@nachtwindheim.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751250AbWHUWLP@vger.kernel.org>
To: Henne <henne@nachtwindheim.de>
Content-Disposition: inline
In-Reply-To: <44EA14BF.5090102@nachtwindheim.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Henne <henne@nachtwindheim.de> :
[...]
> I found a bug in the via-velocity driver, but I cant find a maintainer
> for that, so I write to the lists.
> This driver depends on CONFIG_INET (tcp/ip) if CONFIG_PM is enabled.
> This is tested on i386 and x86_64.
> I'm not familiar with network stuff but I don't believe a device should
> depend on a protocol.

See the comment on top of velocity_get_ip() related to wol and arp.

How does it behave with the patch below:

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3918990..30f21b6 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2173,6 +2173,7 @@ config VIA_VELOCITY
 	select CRC32
 	select CRC_CCITT
 	select MII
+	select INET if PM
 	help
 	  If you have a VIA "Velocity" based network card say Y here.
 

-- 
Ueimor
