From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Thu, 23 Jul 2015 11:58:24 +1000
Message-ID: <20150723115824.071b84ff@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:44415 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753500AbbGWB60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 21:58:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) failed like this:

net/ipv4/ip_tunnel_core.c:301:1: warning: data definition has no type or storage class
 module_init(ip_tunnel_core_init);
 ^
net/ipv4/ip_tunnel_core.c:301:1: error: type defaults to 'int' in declaration of 'module_init' [-Werror=implicit-int]
net/ipv4/ip_tunnel_core.c:301:1: warning: parameter names (without types) in function declaration
net/ipv4/ip_tunnel_core.c:307:1: warning: data definition has no type or storage class
 module_exit(ip_tunnel_core_exit);
 ^
net/ipv4/ip_tunnel_core.c:307:1: error: type defaults to 'int' in declaration of 'module_exit' [-Werror=implicit-int]
net/ipv4/ip_tunnel_core.c:307:1: warning: parameter names (without types) in function declaration
net/ipv4/ip_tunnel_core.c:295:19: warning: 'ip_tunnel_core_init' defined but not used [-Wunused-function]
 static int __init ip_tunnel_core_init(void)
                   ^

Caused by commit

  3093fbe7ff4b ("route: Per route IP tunnel metadata via lightweight tunnel")

Forgot to include module.h ...

I have used the net-next tree from next-20150722 for today.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
