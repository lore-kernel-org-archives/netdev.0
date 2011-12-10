From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/2] udp_diag: Make it module when ipv6 is a module
Date: Sat, 10 Dec 2011 13:33:43 +0400
Message-ID: <4EE32777.2030003@parallels.com>
References: <4EE23561.5020804@parallels.com>	 <4EE23626.6000104@parallels.com> <1323467297.4016.10.camel@edumazet-laptop> <4EE32167.2080202@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21931 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752117Ab1LJJdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 04:33:53 -0500
In-Reply-To: <4EE32167.2080202@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet reported, that when inet_diag is built-in the udp_diag also goes
built-in and when ipv6 is a module the udp6 lookup symbol is not found.

  LD      .tmp_vmlinux1
net/built-in.o: In function `udp_dump_one':
udp_diag.c:(.text+0xa2b40): undefined reference to `__udp6_lib_lookup'
make: *** [.tmp_vmlinux1] Erreur 1

Fix this by making udp diag build mode depend on both -- inet diag and ipv6.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index a51e33e..1a8f93b 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -411,7 +411,7 @@ config INET_TCP_DIAG
 
 config INET_UDP_DIAG
 	depends on INET_DIAG
-	def_tristate INET_DIAG
+	def_tristate INET_DIAG && IPV6
 
 menuconfig TCP_CONG_ADVANCED
 	bool "TCP: advanced congestion control"
