From: Milos Vyletel <milos.vyletel@gmail.com>
Subject: [patch net-next 4/5] Documentation: update ipv6 part of networking/ip-sysctl.txt
Date: Tue, 10 Jun 2014 12:19:12 -0400
Message-ID: <1402417153-2551-5-git-send-email-milos.vyletel@gmail.com>
References: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Cc: Milos Vyletel <milos.vyletel@gmail.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	linux-doc@vger.kernel.org (open list:DOCUMENTATION),
	linux-kernel@vger.kernel.org (open list)
To: davem@davemloft.net, amwang@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:61869 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbaFJQTm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 12:19:42 -0400
In-Reply-To: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Documentation was updated with details how net.ipv6.conf.all settings are
used and how they affect current behaviour and interface-specific settings.

Signed-off-by: Milos Vyletel <milos.vyletel@gmail.com>
---
 Documentation/networking/ip-sysctl.txt | 48 ++++++++++++++++++++++++++++++----
 1 file changed, 43 insertions(+), 5 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index ab42c95..f0406ff 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1159,13 +1159,51 @@ ip6frag_secret_interval - INTEGER
 	Default: 600
 
 conf/default/*:
-	Change the interface-specific default settings.
+	Change the interface-specific default settings. These settings are
+	applied to all interfaces that have not been up and that did not have
+	this settings set previously. This is usually only during boot before
+	network is set up when sysctl settings are applied.
 
 
 conf/all/*:
-	Change all the interface-specific settings.
-
-	[XXX:  Other special features than forwarding?]
+	Change all the interface-specific settings. Different settings have
+	different effect. There are three different groups based on how they
+	treat conf/all vs interface-specific settings. These groups are
+
+	Both conf/all and interface must enable this feature (andconf)
+		- accept_ra_defrtr
+		- accept_ra_pinfo
+		- accept_ra_rtr_pref
+		- accept_redirects
+		- autoconf
+		- force_tllao
+		- mforward
+		- ndisc_notify
+		- suppress_frag_ndisc
+
+	Either conf/all or interface must enable this feature (orconf)
+		- disable_ipv6
+		- proxy_ndp
+
+	Maximum value of conf/all or interface will be used (maxconf)
+		- accept_dad
+		- accept_ra
+		- accept_ra_rt_info_max_plen
+		- accept_source_route
+		- dad_transmits
+		- hop_limit
+		- max_addresses
+		- max_desync_factor
+		- mtu
+		- optimistic_dad
+		- regen_max_retry
+		- router_probe_interval
+		- router_solicitation_delay
+		- router_solicitation_interval
+		- router_solicitations
+		- temp_prefered_lft
+		- temp_valid_lft
+		- use_tempaddr
 
 conf/all/forwarding - BOOLEAN
 	Enable global IPv6 forwarding between all interfaces.
@@ -1414,7 +1452,7 @@ force_mld_version - INTEGER
 	1 - Enforce to use MLD version 1
 	2 - Enforce to use MLD version 2
 
-suppress_frag_ndisc - INTEGER
+suppress_frag_ndisc - BOOLEAN
 	Control RFC 6980 (Security Implications of IPv6 Fragmentation
 	with IPv6 Neighbor Discovery) behavior:
 	1 - (default) discard fragmented neighbor discovery packets
-- 
1.9.0
