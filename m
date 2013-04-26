From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] vxlan: restore source compatibility
Date: Fri, 26 Apr 2013 16:54:44 -0700
Message-ID: <20130426165444.317d4aad@nehalam.linuxnetplumber.net>
References: <877gk2r64z.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Stevens <dlstevens@us.ibm.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40914 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754320Ab3DZXyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 19:54:52 -0400
Received: by mail-pb0-f46.google.com with SMTP id xa7so1301266pbc.5
        for <netdev@vger.kernel.org>; Fri, 26 Apr 2013 16:54:51 -0700 (PDT)
In-Reply-To: <877gk2r64z.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit:
    vxlan: Allow setting destination to unicast address.

Broke source compatibility with exported user headers.
Compile fails with older iproute2 source fails since IFLA_VXLAN_REMOTE not defined.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/include/uapi/linux/if_link.h	2013-04-22 15:44:00.970002724 -0700
+++ b/include/uapi/linux/if_link.h	2013-04-26 16:49:41.709698816 -0700
@@ -298,6 +298,7 @@ enum {
 	IFLA_VXLAN_UNSPEC,
 	IFLA_VXLAN_ID,
 	IFLA_VXLAN_REMOTE,
+#define IFLA_VXLAN_GROUP IFLA_VXLAN_REMOTE
 	IFLA_VXLAN_LINK,
 	IFLA_VXLAN_LOCAL,
 	IFLA_VXLAN_TTL,
