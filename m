From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [iproute2 PATCH 2/4] libnetlink: Modify parser to track the first
	duplicated attributes
Date: Sat, 30 Jan 2010 02:42:46 -0800
Message-ID: <20100130104246.26719.34306.stgit@localhost.localdomain>
References: <20100130104226.26719.21774.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:37685 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750879Ab0A3KnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 05:43:06 -0500
In-Reply-To: <20100130104226.26719.21774.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Modify the parser to keep track of the first of any duplicated attributes,
instead of the last. This is required for VF configuration reporting, where
multiple attributes of the same type are added sequentially.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 lib/libnetlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 4ba6019..cfeb894 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -644,7 +644,7 @@ int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int len)
 {
 	memset(tb, 0, sizeof(struct rtattr *) * (max + 1));
 	while (RTA_OK(rta, len)) {
-		if (rta->rta_type <= max)
+		if ((rta->rta_type <= max) && (!tb[rta->rta_type]))
 			tb[rta->rta_type] = rta;
 		rta = RTA_NEXT(rta,len);
 	}

