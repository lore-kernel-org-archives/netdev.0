From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 5/6] mpls: Fix the openvswitch select of NET_MPLS_GSO
Date: Sat, 07 Mar 2015 16:24:23 -0600
Message-ID: <871tl04fag.fsf@x220.int.ebiederm.org>
References: <874mpw5u3x.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60225 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbbCGW2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 17:28:02 -0500
In-Reply-To: <874mpw5u3x.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sat, 07 Mar 2015 16:18:58 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Fix the OPENVSWITCH Kconfig option and old Kconfigs by having
OPENVSWITCH select both NET_MPLS_GSO and MPLSO.

A Kbuild test robot reported that when NET_MPLS_GSO is selected by
OPENVSWITCH the generated .config is broken because MPLS is not
selected.

Cc: Simon Horman <horms@verge.net.au>
Fixes: cec9166ca4e mpls: Refactor how the mpls module is built
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/openvswitch/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index b7d818c59423..ed6b0f8dd1bb 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -6,6 +6,7 @@ config OPENVSWITCH
 	tristate "Open vSwitch"
 	depends on INET
 	select LIBCRC32C
+	select MPLS
 	select NET_MPLS_GSO
 	---help---
 	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
-- 
2.2.1
