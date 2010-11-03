From: <Narendra_K@Dell.com>
Subject: [PATCH 1/1] UDEV - Add 'udevlom' command line param to start_udev
Date: Wed, 3 Nov 2010 22:25:25 +0530
Message-ID: <20101103165505.GA3281@fedora-14-r710.oslab.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Jordan_Hargrave@Dell.com>, <Charles_Rose@Dell.com>
To: <linux-hotplug@vger.kernel.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patch allows users to specify if they want the onboard network
interfaces to be renamed to lomN by implementing a command line param
'udevlom'.

From: Narendra K <narendra_k@dell.com>
Subject: [PATCH] UDEV - Add 'udevlom' command line param to start_udev

This patch implements 'udevlom' command line parameter, which
when passed, results in onboard network interfaces getting
renamed to lomN.

Signed-off-by: Narendra K <narendra_k@dell.com>
---
 start_udev |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/start_udev b/start_udev
index 49fc286..57d60c9 100755
--- a/start_udev
+++ b/start_udev
@@ -32,6 +32,7 @@ export TZ=/etc/localtime
 . /etc/init.d/functions
 
 prog=udev
+cmdline=`cat /proc/cmdline`
 
 touch_recursive() {
 	( cd $1;
@@ -60,6 +61,10 @@ fi
 
 ret=$[$ret + $?]
 
+if strstr "$cmdline" udevlom; then
+	/sbin/udevadm control --env=UDEVLOM="y"
+fi
+
 /sbin/udevadm trigger --type=subsystems --action=add
 /sbin/udevadm trigger --type=devices --action=add
 /sbin/udevadm settle
-- 
1.7.3.1

With regards,
Narendra K
