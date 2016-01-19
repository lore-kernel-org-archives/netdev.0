From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH 4/8] rfkill: Remove obsolete "claim" sysfs interface
Date: Tue, 19 Jan 2016 10:42:39 -0500
Message-ID: <1453218163-31998-5-git-send-email-jprvita@endlessm.com>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jprvita@endlessm.com,
	linux@endlessm.com
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was schedule to be removed in 2012 by:

 commit 69c86373c6ea1149aa559e6088362d58d8ec8835
 Author: florian@mickler.org <florian@mickler.org>
 Date:   Wed Feb 24 12:05:16 2010 +0100

     Document the rfkill sysfs ABI

     This moves sysfs ABI info from Documentation/rfkill.txt to the
     ABI subfolder and reformats it.

     This also schedules the deprecated sysfs parts to be removed in
     2012 (claim file) and 2014 (state file).

     Signed-off-by: Florian Mickler <florian@mickler.org>
     Signed-off-by: John W. Linville <linville@tuxdriver.com>

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 Documentation/ABI/obsolete/sysfs-class-rfkill |  9 ---------
 Documentation/ABI/removed/sysfs-class-rfkill  | 13 +++++++++++++
 net/rfkill/core.c                             | 11 +----------
 3 files changed, 14 insertions(+), 19 deletions(-)
 create mode 100644 Documentation/ABI/removed/sysfs-class-rfkill

diff --git a/Documentation/ABI/obsolete/sysfs-class-rfkill b/Documentat=
ion/ABI/obsolete/sysfs-class-rfkill
index ff60ad9..e736d14 100644
--- a/Documentation/ABI/obsolete/sysfs-class-rfkill
+++ b/Documentation/ABI/obsolete/sysfs-class-rfkill
@@ -18,12 +18,3 @@ Values: 	A numeric value.
 		2: RFKILL_STATE_HARD_BLOCKED
 			transmitter is forced off by something outside of
 			the driver's control.
-
-What:		/sys/class/rfkill/rfkill[0-9]+/claim
-Date:		09-Jul-2007
-KernelVersion	v2.6.22
-Contact:	linux-wireless@vger.kernel.org
-Description:	This file is deprecated because there no longer is a way =
to
-		claim just control over a single rfkill instance.
-		This file is scheduled to be removed in 2012.
-Values: 	0: Kernel handles events
diff --git a/Documentation/ABI/removed/sysfs-class-rfkill b/Documentati=
on/ABI/removed/sysfs-class-rfkill
new file mode 100644
index 0000000..3ce6231
--- /dev/null
+++ b/Documentation/ABI/removed/sysfs-class-rfkill
@@ -0,0 +1,13 @@
+rfkill - radio frequency (RF) connector kill switch support
+
+For details to this subsystem look at Documentation/rfkill.txt.
+
+What:		/sys/class/rfkill/rfkill[0-9]+/claim
+Date:		09-Jul-2007
+KernelVersion	v2.6.22
+Contact:	linux-wireless@vger.kernel.org
+Description:	This file was deprecated because there no longer was a wa=
y to
+		claim just control over a single rfkill instance.
+		This file was scheduled to be removed in 2012, and was removed
+		in 2016.
+Values: 	0: Kernel handles events
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 5406c76..a05d1f1 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -309,8 +309,7 @@ static atomic_t rfkill_input_disabled =3D ATOMIC_IN=
IT(0);
  * @blocked: the new state
  *
  * This function sets the state of all switches of given type,
- * unless a specific switch is claimed by userspace (in which case,
- * that switch is left alone) or suspended.
+ * unless a specific switch is suspended.
  *
  * Caller must have acquired rfkill_global_mutex.
  */
@@ -718,20 +717,12 @@ static ssize_t state_store(struct device *dev, st=
ruct device_attribute *attr,
 }
 static DEVICE_ATTR_RW(state);
=20
-static ssize_t claim_show(struct device *dev, struct device_attribute =
*attr,
-			  char *buf)
-{
-	return sprintf(buf, "%d\n", 0);
-}
-static DEVICE_ATTR_RO(claim);
-
 static struct attribute *rfkill_dev_attrs[] =3D {
 	&dev_attr_name.attr,
 	&dev_attr_type.attr,
 	&dev_attr_index.attr,
 	&dev_attr_persistent.attr,
 	&dev_attr_state.attr,
-	&dev_attr_claim.attr,
 	&dev_attr_soft.attr,
 	&dev_attr_hard.attr,
 	NULL,
--=20
2.5.0
