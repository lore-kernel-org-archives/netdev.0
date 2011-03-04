From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH] net: Enter net/ipv6/ even if CONFIG_IPV6=n
Date: Fri, 4 Mar 2011 04:35:07 -0500
Message-ID: <20110304093507.GG10761@canuck.infradead.org>
References: <20110210180525.54ec83e9.sfr@canb.auug.org.au>
 <20110210095210.6fcf3011.randy.dunlap@oracle.com>
 <4D58DB20.5060401@trash.net>
 <20110303135414.bfcabb2a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	Randy Dunlap <randy.dunlap@oracle.com>
To: davem@davemloft.net
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110303135414.bfcabb2a.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

exthdrs_core.c and addrconf_core.c in net/ipv6/ contain bits which
must be made available even if IPv6 is disabled.

net/ipv6/Makefile already correctly includes them if CONFIG_IPV6=n
but net/Makefile prevents entering the subdirectory.

Signed-off-by: Thomas Graf <tgraf@infradead.org>

diff --git a/net/Makefile b/net/Makefile
index a3330eb..a51d946 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -19,9 +19,7 @@ obj-$(CONFIG_NETFILTER)		+= netfilter/
 obj-$(CONFIG_INET)		+= ipv4/
 obj-$(CONFIG_XFRM)		+= xfrm/
 obj-$(CONFIG_UNIX)		+= unix/
-ifneq ($(CONFIG_IPV6),)
-obj-y				+= ipv6/
-endif
+obj-$(CONFIG_NET)		+= ipv6/
 obj-$(CONFIG_PACKET)		+= packet/
 obj-$(CONFIG_NET_KEY)		+= key/
 obj-$(CONFIG_BRIDGE)		+= bridge/
