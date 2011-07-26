From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 11/14] userns: make some net-sysfs capable calls targeted
Date: Tue, 26 Jul 2011 18:58:34 +0000
Message-ID: <1311706717-7398-12-git-send-email-serge@hallyn.com>
References: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Cc: dhowells@redhat.com, ebiederm@xmission.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	akpm@osdl.org, "Serge E. Hallyn" <serge.hallyn@canonical.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1311706717-7398-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Serge E. Hallyn <serge.hallyn@canonical.com>

Changelog: jul 1: fix compilation errors (net_device != net)

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
---
 net/core/net-sysfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1683e5d..876915b 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -76,7 +76,7 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,
 	unsigned long new;
 	int ret = -EINVAL;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(net)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	new = simple_strtoul(buf, &endp, 0);
@@ -261,7 +261,7 @@ static ssize_t store_ifalias(struct device *dev, struct device_attribute *attr,
 	size_t count = len;
 	ssize_t ret;
 
-	if (!capable(CAP_NET_ADMIN))
+	if (!ns_capable(dev_net(netdev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 
 	/* ignore trailing newline */
-- 
1.7.4.1
