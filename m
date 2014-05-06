From: David Decotigny <decot@googlers.com>
Subject: [PATCH v1] net-sysfs: expose permanent hardware address in sysfs
Date: Mon,  5 May 2014 20:34:00 -0700
Message-ID: <cd90d330753ff145d209240a72caafac32f5e750.1399347193.git.decot@googlers.com>
References: <cover.1399347193.git.decot@googlers.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Eric Dumazet <edumazet@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Weilong Chen <chenweilong@huawei.com>,
	David Decotigny <decot@googlers.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Michael Dalton <mwdalton@google.com>,
	Al Viro <viro@ZenIV.linux.org.uk>, Tejun Heo <tj@kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1399347193.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tested:
  grep . /sys/class/net/*/*addr*

Signed-off-by: David Decotigny <decot@googlers.com>
---
 net/core/net-sysfs.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1cac29e..bf57024 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -127,6 +127,20 @@ static ssize_t address_show(struct device *dev, struct device_attribute *attr,
 }
 static DEVICE_ATTR_RO(address);
 
+static ssize_t perm_addr_show(struct device *dev, struct device_attribute *attr,
+			      char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	ssize_t ret = -EINVAL;
+
+	read_lock(&dev_base_lock);
+	if (dev_isalive(net))
+		ret = sysfs_format_mac(buf, net->perm_addr, net->addr_len);
+	read_unlock(&dev_base_lock);
+	return ret;
+}
+static DEVICE_ATTR_RO(perm_addr);
+
 static ssize_t broadcast_show(struct device *dev,
 			      struct device_attribute *attr, char *buf)
 {
@@ -391,6 +405,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_addr_len.attr,
 	&dev_attr_link_mode.attr,
 	&dev_attr_address.attr,
+	&dev_attr_perm_addr.attr,
 	&dev_attr_broadcast.attr,
 	&dev_attr_speed.attr,
 	&dev_attr_duplex.attr,
-- 
1.9.1.423.g4596e3a
