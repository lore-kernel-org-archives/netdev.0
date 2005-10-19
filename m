From: Maxime Bizon <mbizon@freebox.fr>
Subject: [PATCH] ipconfig.c: fix dhcp timeout leading to bad requested
	address.
Date: Wed, 19 Oct 2005 21:43:32 +0200
Message-ID: <1129751012.1724.13.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello,

There is still a little bug in dhcp timeout handling.

When DHCPOFFER is received, offered and server addresses are kept. If no
ack is received, ic_myaddr is reset to INADDR_NONE, but not ic_servaddr.

The problem is that ic_dhcp_init_options() checks only ic_servaddr to
known if it has to send a DHCPOFFER or a DHCPREQUEST. So packets sent
after a timeout will be DHCPREQUEST with requested address INADDR_NONE.

If the the dhcp server does not NAK it, this request is done forever.

The following patch fixes this.


Signed-off-by: Maxime Bizon <mbizon@freebox.fr>

--- linux-2.6.13.4/net/ipv4/ipconfig.c.orig	2005-10-18 18:11:54.000000000 +0200
+++ linux-2.6.13.4/net/ipv4/ipconfig.c	2005-10-19 20:44:07.000000000 +0200
@@ -1151,6 +1151,7 @@
 
 	if (!ic_got_reply) {
 		ic_myaddr = INADDR_NONE;
+		ic_servaddr = INADDR_NONE;
 		return -1;
 	}


-- 
Maxime
