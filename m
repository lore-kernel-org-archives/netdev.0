From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [iproute2 PATCH v2 2/4] libnetlink: Modify the parser to track first
	duplicated attributes
Date: Wed, 10 Feb 2010 03:46:47 -0800
Message-ID: <20100210114646.14570.87012.stgit@localhost.localdomain>
References: <20100210114617.14570.87620.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:42049
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753977Ab0BJLrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 06:47:08 -0500
In-Reply-To: <20100210114617.14570.87620.stgit@localhost.localdomain>
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

