From: Thomas Graf <tgraf@infradead.org>
Subject: [PATCH net-2.6] ipv6: Expose IFLA_PROTINFO timer values in msecs
 instead of jiffies
Date: Wed, 17 Nov 2010 06:44:24 -0500
Message-ID: <20101117114424.GA5838@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([134.117.69.58]:58230 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932962Ab0KQLoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 06:44:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFLA_PROTINFO exposes timer related per device settings in jiffies.
Change it to expose these values in msecs like the sysctl interface
does.

I did not find any users of IFLA_PROTINFO which rely on any of these
values and even if there are, they are likely already broken because
there is no way for them to reliably convert such a value to another
time format.

Signed-off-by: Thomas Graf <tgraf@infradead.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Index: net-2.6/net/ipv6/addrconf.c
===================================================================
--- net-2.6.orig/net/ipv6/addrconf.c
+++ net-2.6/net/ipv6/addrconf.c
@@ -3798,8 +3798,10 @@ static inline void ipv6_store_devconf(st
 	array[DEVCONF_AUTOCONF] = cnf->autoconf;
 	array[DEVCONF_DAD_TRANSMITS] = cnf->dad_transmits;
 	array[DEVCONF_RTR_SOLICITS] = cnf->rtr_solicits;
-	array[DEVCONF_RTR_SOLICIT_INTERVAL] = cnf->rtr_solicit_interval;
-	array[DEVCONF_RTR_SOLICIT_DELAY] = cnf->rtr_solicit_delay;
+	array[DEVCONF_RTR_SOLICIT_INTERVAL] =
+		jiffies_to_msecs(cnf->rtr_solicit_interval);
+	array[DEVCONF_RTR_SOLICIT_DELAY] =
+		jiffies_to_msecs(cnf->rtr_solicit_delay);
 	array[DEVCONF_FORCE_MLD_VERSION] = cnf->force_mld_version;
 #ifdef CONFIG_IPV6_PRIVACY
 	array[DEVCONF_USE_TEMPADDR] = cnf->use_tempaddr;
@@ -3813,7 +3815,8 @@ static inline void ipv6_store_devconf(st
 	array[DEVCONF_ACCEPT_RA_PINFO] = cnf->accept_ra_pinfo;
 #ifdef CONFIG_IPV6_ROUTER_PREF
 	array[DEVCONF_ACCEPT_RA_RTR_PREF] = cnf->accept_ra_rtr_pref;
-	array[DEVCONF_RTR_PROBE_INTERVAL] = cnf->rtr_probe_interval;
+	array[DEVCONF_RTR_PROBE_INTERVAL] =
+		jiffies_to_msecs(cnf->rtr_probe_interval);
 #ifdef CONFIG_IPV6_ROUTE_INFO
 	array[DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN] = cnf->accept_ra_rt_info_max_plen;
 #endif
