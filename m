From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ip_tunnel, bpf: ip_tunnel_info_opts_{get,set} depends on CONFIG_INET
Date: Tue,  8 Mar 2016 23:36:03 +0100
Message-ID: <3ecfa7ed9f730147c925e010907cf920b8071a27.1457476284.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	fengguang.wu@intel.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57131 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbcCHWwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 17:52:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Helpers like ip_tunnel_info_opts_{get,set}() are only available if
CONFIG_INET is set, thus add an empty definition into the header for
the !CONFIG_INET case, where already other empty inline helpers are
defined.

This avoids ifdef kludge inside filter.c, but also vxlan and geneve
themself where this facility can only be used with, depend on INET
being set. For the !INET case TUNNEL_OPTIONS_PRESENT would never be
set in flags.

Fixes: 14ca0751c96f ("bpf: support for access to tunnel options")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/ip_tunnels.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index e1395d7..0acd80f 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -369,6 +369,17 @@ static inline void ip_tunnel_unneed_metadata(void)
 {
 }
 
+static inline void ip_tunnel_info_opts_get(void *to,
+					   const struct ip_tunnel_info *info)
+{
+}
+
+static inline void ip_tunnel_info_opts_set(struct ip_tunnel_info *info,
+					   const void *from, int len)
+{
+	info->options_len = 0;
+}
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
-- 
1.9.3
