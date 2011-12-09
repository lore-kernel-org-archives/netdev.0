From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH] Revert "net: netprio_cgroup: make net_prio_subsys static"
Date: Fri, 09 Dec 2011 09:03:25 -0800
Message-ID: <20111209170325.26422.11885.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33968 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970Ab1LIRNj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 12:13:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 865d9f9f748fdc1943679ea65d9ee1dc55e4a6ae.

This commit breaks the build with CONFIG_NETPRIO_CGROUP=y so
revert it. It does build as a module though. The SUBSYS macro
in the cgroup core code automatically defines a subsys structure
as extern. Long term we should fix the macro. And I need to
fully build test things.

Tested with CONFIG_NETPRIO_CGROUP={y|m|n} with and without
CONFIG_CGROUPS defined.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
CC: Neil Horman <nhorman@tuxdriver.com>
Reported-By: Eric Dumazet <eric.dumazet@gmail.com>
---

 net/core/netprio_cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index ea16c8f..3a9fd48 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -28,7 +28,7 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
 static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
 
-static struct cgroup_subsys net_prio_subsys = {
+struct cgroup_subsys net_prio_subsys = {
 	.name		= "net_prio",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
