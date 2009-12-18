From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC iproute2 PATCH 2/3] iproute: Modify the parser's handling
	duplicated attributes
Date: Thu, 17 Dec 2009 17:37:43 -0800
Message-ID: <20091218013743.4663.33018.stgit@localhost.localdomain>
References: <20091218013727.4663.86820.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:36136 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755844AbZLRBh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 20:37:58 -0500
In-Reply-To: <20091218013727.4663.86820.stgit@localhost.localdomain>
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
index a6c0306..23c40f1 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -628,7 +628,7 @@ int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int len)
 {
 	memset(tb, 0, sizeof(struct rtattr *) * (max + 1));
 	while (RTA_OK(rta, len)) {
-		if (rta->rta_type <= max)
+		if ((rta->rta_type <= max) && (!tb[rta->rta_type]))
 			tb[rta->rta_type] = rta;
 		rta = RTA_NEXT(rta,len);
 	}

