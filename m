From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH 4/9] rfkill: Move "state" sysfs file back to stable
Date: Mon,  8 Feb 2016 10:41:31 -0500
Message-ID: <1454946096-9752-5-git-send-email-jprvita@endlessm.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is still quite a bit of code using this interface, so we can't
just remove it. Hopefully it will be possible in the future, but since
its scheduled removal date is past 2 years already, we are better havin=
g
the documentation reflecting the current state of things.

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 Documentation/ABI/obsolete/sysfs-class-rfkill | 20 -------------------=
-
 Documentation/ABI/stable/sysfs-class-rfkill   | 25 +++++++++++++++++++=
+++---
 2 files changed, 22 insertions(+), 23 deletions(-)
 delete mode 100644 Documentation/ABI/obsolete/sysfs-class-rfkill

diff --git a/Documentation/ABI/obsolete/sysfs-class-rfkill b/Documentat=
ion/ABI/obsolete/sysfs-class-rfkill
deleted file mode 100644
index e736d14..0000000
--- a/Documentation/ABI/obsolete/sysfs-class-rfkill
+++ /dev/null
@@ -1,20 +0,0 @@
-rfkill - radio frequency (RF) connector kill switch support
-
-For details to this subsystem look at Documentation/rfkill.txt.
-
-What:		/sys/class/rfkill/rfkill[0-9]+/state
-Date:		09-Jul-2007
-KernelVersion	v2.6.22
-Contact:	linux-wireless@vger.kernel.org
-Description: 	Current state of the transmitter.
-		This file is deprecated and scheduled to be removed in 2014,
-		because its not possible to express the 'soft and hard block'
-		state of the rfkill driver.
-Values: 	A numeric value.
-		0: RFKILL_STATE_SOFT_BLOCKED
-			transmitter is turned off by software
-		1: RFKILL_STATE_UNBLOCKED
-			transmitter is (potentially) active
-		2: RFKILL_STATE_HARD_BLOCKED
-			transmitter is forced off by something outside of
-			the driver's control.
diff --git a/Documentation/ABI/stable/sysfs-class-rfkill b/Documentatio=
n/ABI/stable/sysfs-class-rfkill
index e51571e..e1ba4a1 100644
--- a/Documentation/ABI/stable/sysfs-class-rfkill
+++ b/Documentation/ABI/stable/sysfs-class-rfkill
@@ -5,9 +5,6 @@ For details to this subsystem look at Documentation/rfk=
ill.txt.
 For the deprecated /sys/class/rfkill/*/claim knobs of this interface l=
ook in
 Documentation/ABI/removed/sysfs-class-rfkill.
=20
-For the deprecated /sys/class/rfkill/*/state knobs of this interface l=
ook in
-Documentation/ABI/obsolete/sysfs-class-rfkill.
-
 What: 		/sys/class/rfkill
 Date:		09-Jul-2007
 KernelVersion:	v2.6.22
@@ -44,6 +41,28 @@ Values: 	A numeric value.
 		1: true
=20
=20
+What:		/sys/class/rfkill/rfkill[0-9]+/state
+Date:		09-Jul-2007
+KernelVersion	v2.6.22
+Contact:	linux-wireless@vger.kernel.org
+Description: 	Current state of the transmitter.
+		This file was scheduled to be removed in 2014, but due to its
+		large number of users it will be sticking around for a bit
+		longer. Despite it being marked as stabe, the newer "hard" and
+		"soft" interfaces should be preffered, since it is not possible
+		to express the 'soft and hard block' state of the rfkill driver
+		through this interface. There will likely be another attempt to
+		remove it in the future.
+Values: 	A numeric value.
+		0: RFKILL_STATE_SOFT_BLOCKED
+			transmitter is turned off by software
+		1: RFKILL_STATE_UNBLOCKED
+			transmitter is (potentially) active
+		2: RFKILL_STATE_HARD_BLOCKED
+			transmitter is forced off by something outside of
+			the driver's control.
+
+
 What:		/sys/class/rfkill/rfkill[0-9]+/hard
 Date:		12-March-2010
 KernelVersion	v2.6.34
--=20
2.5.0
