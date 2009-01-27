From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] iproute2: 0 out memory for tc_skbedit struct prior to using
	it.
Date: Mon, 26 Jan 2009 19:20:28 -0800
Message-ID: <20090127032028.26631.27015.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:56480 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752044AbZA0DUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 22:20:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

A bug was found in which the memory for the tc_skbedit struct was being
used uninitialized to 0.  This patch corrects the issue by using a memset
to 0 out the memory of the structure.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 tc/m_skbedit.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 55e3f89..0e50fbc 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -57,6 +57,8 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	__u16 queue_mapping;
 	__u32 flags = 0, priority;
 
+	memset(&sel, 0, sizeof(struct tc_skbedit));
+
 	if (matches(*argv, "skbedit") != 0)
 		return -1;
 

