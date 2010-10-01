From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Fri, 1 Oct 2010 12:48:35 +1000
Message-ID: <20101001124835.a4315b5b.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Kozlov <xeb@mail.ru>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:52062 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510Ab0JACsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 22:48:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/ipv4/Kconfig between commit 68c1f3a96c32a4fe15ebadae45c8145a5e5a66d2
("ip_gre: Fix dependencies wrt. ipv6") from the net-current tree and
commit 00959ade36acadc00e757f87060bf6e4501d545f ("PPTP: PPP over IPv4
(Point-to-Point Tunneling Protocol)") from the net tree.

Just overlapping additions.  I fixed it up (see below) and can carry the
fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/Kconfig
index 72380a3,5462e2d..0000000
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@@ -215,9 -215,15 +215,16 @@@ config NET_IPI
  	  be inserted in and removed from the running kernel whenever you
  	  want). Most people won't need this and can say N.
  
+ config NET_IPGRE_DEMUX
+ 	tristate "IP: GRE demultiplexer"
+ 	help
+ 	 This is helper module to demultiplex GRE packets on GRE version field criteria.
+ 	 Required by ip_gre and pptp modules.
+ 
  config NET_IPGRE
  	tristate "IP: GRE tunnels over IP"
 +	depends on IPV6 || IPV6=n
+ 	depends on NET_IPGRE_DEMUX
  	help
  	  Tunneling means encapsulating data of one protocol type within
  	  another protocol and sending it over a channel that understands the
