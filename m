From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Mon, 02 Feb 2009 13:27:23 -0800 (PST)
Message-ID: <20090202.132723.38842373.davem@davemloft.net>
References: <20090202.120507.152093960.davem@davemloft.net>
	<498761E7.3080006@walrond.org>
	<20090202.132450.21504465.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, sam@ravnborg.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: andrew@walrond.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39402
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753011AbZBBV10 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:27:26 -0500
In-Reply-To: <20090202.132450.21504465.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 02 Feb 2009 13:24:50 -0800 (PST)

> I guess I'll put in the following hack for now:
> 
> diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
> index aeab2cb..82c4362 100644

Need to also update linux/Kbuild, here is an updated patch:

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 12e9a29..6a9bb97 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -89,7 +89,6 @@ header-y += if_ppp.h
 header-y += if_slip.h
 header-y += if_strip.h
 header-y += if_tun.h
-header-y += if_tunnel.h
 header-y += in_route.h
 header-y += ioctl.h
 header-y += ip6_tunnel.h
@@ -235,6 +234,7 @@ unifdef-y += if_phonet.h
 unifdef-y += if_pppol2tp.h
 unifdef-y += if_pppox.h
 unifdef-y += if_tr.h
+unifdef-y += if_tunnel.h
 unifdef-y += if_vlan.h
 unifdef-y += igmp.h
 unifdef-y += inet_diag.h
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index aeab2cb..82c4362 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -2,7 +2,10 @@
 #define _IF_TUNNEL_H_
 
 #include <linux/types.h>
+
+#ifdef __KERNEL__
 #include <linux/ip.h>
+#endif
 
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
