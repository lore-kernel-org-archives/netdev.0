From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH 3/5] kobject: kset_create_and_add() - fetch ownership info from parent
Date: Tue, 16 Aug 2016 15:33:13 -0700
Message-ID: <1471386795-32918-4-git-send-email-dmitry.torokhov@gmail.com>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change implements get_ownership() for ksets created with
kset_create_and_add() call by fetching ownership data from parent kobject.
This is done mostly for benefit of "queues" attribute of net devices so
that corresponding directory belongs to container's root instead of global
root for network devices in a container.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 lib/kobject.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/lib/kobject.c b/lib/kobject.c
index 7d516d9..f81ac7c 100644
--- a/lib/kobject.c
+++ b/lib/kobject.c
@@ -890,9 +890,16 @@ static void kset_release(struct kobject *kobj)
 	kfree(kset);
 }
 
+void kset_get_ownership(struct kobject *kobj, kuid_t *uid, kgid_t *gid)
+{
+	if (kobj->parent)
+		kobject_get_ownership(kobj->parent, uid, gid);
+}
+
 static struct kobj_type kset_ktype = {
 	.sysfs_ops	= &kobj_sysfs_ops,
-	.release = kset_release,
+	.release	= kset_release,
+	.get_ownership	= kset_get_ownership,
 };
 
 /**
-- 
2.8.0.rc3.226.g39d4020
