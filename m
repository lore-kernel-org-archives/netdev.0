From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH] Documentation: cgroup: add documentation for net_cls cgroups.
Date: Mon,  8 Apr 2013 17:04:20 +0300
Message-ID: <1365429860-3184-1-git-send-email-ramirose@gmail.com>
Cc: tj@kernel.org, lizefan@huawei.com, netdev@vger.kernel.org,
	tgraf@suug.ch, Rami Rosen <ramirose@gmail.com>
To: cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:46835 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964876Ab3DHOEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 10:04:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new file, Documentation/cgroups/net_cls.txt, with info
about net_cls cgroups, and updates the 00-INDEX accordingly.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 Documentation/cgroups/00-INDEX    |  2 ++
 Documentation/cgroups/net_cls.txt | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+)
 create mode 100644 Documentation/cgroups/net_cls.txt

diff --git a/Documentation/cgroups/00-INDEX b/Documentation/cgroups/00-INDEX
index f5635a0..bc461b6 100644
--- a/Documentation/cgroups/00-INDEX
+++ b/Documentation/cgroups/00-INDEX
@@ -18,6 +18,8 @@ memcg_test.txt
 	- Memory Resource Controller; implementation details.
 memory.txt
 	- Memory Resource Controller; design, accounting, interface, testing.
+net_cls.txt
+	- Network classifier cgroups details and usages.
 net_prio.txt
 	- Network priority cgroups details and usages.
 resource_counter.txt
diff --git a/Documentation/cgroups/net_cls.txt b/Documentation/cgroups/net_cls.txt
new file mode 100644
index 0000000..9face6b
--- /dev/null
+++ b/Documentation/cgroups/net_cls.txt
@@ -0,0 +1,34 @@
+Network classifier cgroup
+-------------------------
+
+The Network classifier cgroup provides an interface to
+tag network packets with a class identifier (classid).
+
+The Traffic Controller (tc) can be used to assign
+different priorities to packets from different cgroups.
+
+Creating a net_cls cgroups instance creates a net_cls.classid file.
+This net_cls.classid value is initialized to 0.
+
+You can write hexadecimal values to net_cls.classid; the format for these
+values is 0xAAAABBBB; AAAA is the major handle number and BBBB
+is the minor handle number.
+Reading net_cls.classid yields a decimal result.
+
+Example:
+mkdir /sys/fs/cgroup/net_cls
+mount -t cgroup -onet_cls net_cls /sys/fs/cgroup/net_cls
+mkdir /sys/fs/cgroup/net_cls/0
+echo 0x100001 >  /sys/fs/cgroup/net_cls/0/net_cls.classid
+	- setting a 10:1 handle.
+
+cat /sys/fs/cgroup/net_cls/0/net_cls.classid
+1048577
+
+configuring tc:
+tc qdisc add dev eth0 root handle 10: htb
+
+tc class add dev eth0 parent 10: classid 10:1 htb rate 40mbit
+ - creating traffic class 10:1
+
+tc filter add dev eth0 parent 10: protocol ip prio 10 handle 1: cgroup
-- 
1.8.1.4
