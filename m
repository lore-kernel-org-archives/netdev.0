From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 05/14] atm: use list_for_each_entry
Date: Fri, 18 Dec 2015 23:33:29 +0800
Message-ID: <e61fdf4b8da488ac268ecb89bb8e6e16a4e4c3bb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry() instead of list_for_each() to simplify
the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/atm/ioctl.c     | 5 ++---
 net/atm/resources.c | 8 ++------
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index bbd3b63..9feb293 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -53,7 +53,7 @@ static int do_vcc_ioctl(struct socket *sock, unsigned int cmd,
 	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
 	int error;
-	struct list_head *pos;
+	struct atm_ioctl *ic;
 	void __user *argp = (void __user *)arg;
 
 	vcc = ATM_SD(sock);
@@ -163,8 +163,7 @@ static int do_vcc_ioctl(struct socket *sock, unsigned int cmd,
 	error = -ENOIOCTLCMD;
 
 	mutex_lock(&ioctl_mutex);
-	list_for_each(pos, &ioctl_list) {
-		struct atm_ioctl *ic = list_entry(pos, struct atm_ioctl, list);
+	list_for_each_entry(ic, &ioctl_list, list) {
 		if (try_module_get(ic->owner)) {
 			error = ic->ioctl(sock, cmd, arg);
 			module_put(ic->owner);
diff --git a/net/atm/resources.c b/net/atm/resources.c
index 0447d5d..413d919 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -51,10 +51,8 @@ static struct atm_dev *__alloc_atm_dev(const char *type)
 static struct atm_dev *__atm_dev_lookup(int number)
 {
 	struct atm_dev *dev;
-	struct list_head *p;
 
-	list_for_each(p, &atm_devs) {
-		dev = list_entry(p, struct atm_dev, dev_list);
+	list_for_each_entry(dev, &atm_devs, dev_list) {
 		if (dev->number == number) {
 			atm_dev_hold(dev);
 			return dev;
@@ -238,10 +236,8 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg, int compat)
 			return -ENOMEM;
 		}
 		tmp_p = tmp_buf;
-		list_for_each(p, &atm_devs) {
-			dev = list_entry(p, struct atm_dev, dev_list);
+		list_for_each_entry(dev, &atm_devs, dev_list)
 			*tmp_p++ = dev->number;
-		}
 		mutex_unlock(&atm_dev_mutex);
 		error = ((copy_to_user(buf, tmp_buf, size)) ||
 			 put_user(size, iobuf_len))
-- 
2.5.0
