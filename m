From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] l2tp: fix compile error when CONFIG_IPV6=m and CONFIG_L2TP=y
Date: Tue, 18 Sep 2012 13:54:02 +0800
Message-ID: <1347947642-20330-1-git-send-email-amwang@redhat.com>
Cc: David Miller <davem@davemloft.net>, Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754613Ab2IRFyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 01:54:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_IPV6=m and CONFIG_L2TP=y, I got the following compile error:

  LD      init/built-in.o
net/built-in.o: In function `l2tp_xmit_core':
l2tp_core.c:(.text+0x147781): undefined reference to `inet6_csk_xmit'
net/built-in.o: In function `l2tp_tunnel_create':
(.text+0x149067): undefined reference to `udpv6_encap_enable'
net/built-in.o: In function `l2tp_ip6_recvmsg':
l2tp_ip6.c:(.text+0x14e991): undefined reference to `ipv6_recv_error'
net/built-in.o: In function `l2tp_ip6_sendmsg':
l2tp_ip6.c:(.text+0x14ec64): undefined reference to `fl6_sock_lookup'
l2tp_ip6.c:(.text+0x14ed6b): undefined reference to `datagram_send_ctl'
l2tp_ip6.c:(.text+0x14eda0): undefined reference to `fl6_sock_lookup'
l2tp_ip6.c:(.text+0x14ede5): undefined reference to `fl6_merge_options'
l2tp_ip6.c:(.text+0x14edf4): undefined reference to `ipv6_fixup_options'
l2tp_ip6.c:(.text+0x14ee5d): undefined reference to `fl6_update_dst'
l2tp_ip6.c:(.text+0x14eea3): undefined reference to `ip6_dst_lookup_flow'
l2tp_ip6.c:(.text+0x14eee7): undefined reference to `ip6_dst_hoplimit'
l2tp_ip6.c:(.text+0x14ef8b): undefined reference to `ip6_append_data'
l2tp_ip6.c:(.text+0x14ef9d): undefined reference to `ip6_flush_pending_frames'
l2tp_ip6.c:(.text+0x14efe2): undefined reference to `ip6_push_pending_frames'
net/built-in.o: In function `l2tp_ip6_destroy_sock':
l2tp_ip6.c:(.text+0x14f090): undefined reference to `ip6_flush_pending_frames'
l2tp_ip6.c:(.text+0x14f0a0): undefined reference to `inet6_destroy_sock'
net/built-in.o: In function `l2tp_ip6_connect':
l2tp_ip6.c:(.text+0x14f14d): undefined reference to `ip6_datagram_connect'
net/built-in.o: In function `l2tp_ip6_bind':
l2tp_ip6.c:(.text+0x14f4fe): undefined reference to `ipv6_chk_addr'
net/built-in.o: In function `l2tp_ip6_init':
l2tp_ip6.c:(.init.text+0x73fa): undefined reference to `inet6_add_protocol'
l2tp_ip6.c:(.init.text+0x740c): undefined reference to `inet6_register_protosw'
net/built-in.o: In function `l2tp_ip6_exit':
l2tp_ip6.c:(.exit.text+0x1954): undefined reference to `inet6_unregister_protosw'
l2tp_ip6.c:(.exit.text+0x1965): undefined reference to `inet6_del_protocol'
net/built-in.o:(.rodata+0xf2d0): undefined reference to `inet6_release'
net/built-in.o:(.rodata+0xf2d8): undefined reference to `inet6_bind'
net/built-in.o:(.rodata+0xf308): undefined reference to `inet6_ioctl'
net/built-in.o:(.data+0x1af40): undefined reference to `ipv6_setsockopt'
net/built-in.o:(.data+0x1af48): undefined reference to `ipv6_getsockopt'
net/built-in.o:(.data+0x1af50): undefined reference to `compat_ipv6_setsockopt'
net/built-in.o:(.data+0x1af58): undefined reference to `compat_ipv6_getsockopt'
make: *** [vmlinux] Error 1

This is due to l2tp uses symbols from IPV6, so when l2tp is
builtin, IPV6 has to be builtin too.

Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/net/l2tp/Kconfig b/net/l2tp/Kconfig
index 4b1e717..3f3c514 100644
--- a/net/l2tp/Kconfig
+++ b/net/l2tp/Kconfig
@@ -4,6 +4,7 @@
 
 menuconfig L2TP
 	tristate "Layer Two Tunneling Protocol (L2TP)"
+	select IPV6 if L2TP=y
 	depends on INET
 	---help---
 	  Layer Two Tunneling Protocol
