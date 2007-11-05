From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] remove Documentation/networking/pt.txt
Date: Mon, 5 Nov 2007 18:05:57 +0100
Message-ID: <20071105170557.GT12045@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757307AbXKERGq@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no no point in keeping documentation for a driver that was 
removed many years ago.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 Documentation/networking/00-INDEX |    2 -
 Documentation/networking/pt.txt   |   58 ------------------------------
 2 files changed, 60 deletions(-)

cfe9580e99bc2406a5a05bae24487ca84619bec7 
diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
index 9c64042..5e21f37 100644
--- a/Documentation/networking/00-INDEX
+++ b/Documentation/networking/00-INDEX
@@ -80,6 +80,4 @@ olympic.txt
 policy-routing.txt
 	- IP policy-based routing
-pt.txt
-	- the Gracilis Packetwin AX.25 device driver
 ray_cs.txt
 	- Raylink Wireless LAN card driver info.
diff --git a/Documentation/networking/pt.txt b/Documentation/networking/pt.txt
deleted file mode 100644
index 72e888c..0000000
--- a/Documentation/networking/pt.txt
+++ /dev/null
@@ -1,58 +0,0 @@
-This is the README for the Gracilis Packetwin device driver, version 0.5
-ALPHA for Linux 1.3.43.
-
-These files will allow you to talk to the PackeTwin (now know as PT) and
-connect through it just like a pair of TNCs.  To do this you will also
-require the AX.25 code in the kernel enabled.
-
-There are four files in this archive; this readme, a patch file, a .c file
-and finally a .h file.  The two program files need to be put into the
-drivers/net directory in the Linux source tree, for me this is the
-directory /usr/src/linux/drivers/net.  The patch file needs to be patched in
-at the top of the Linux source tree (/usr/src/linux in my case).
-
-You will most probably have to edit the pt.c file to suit your own setup,
-this should just involve changing some of the defines at the top of the file. 
-Please note that if you run an external modem you must specify a speed of 0.
-
-The program is currently setup to run a 4800 baud external modem on port A
-and a Kantronics DE-9600 daughter board on port B so if you have this (or
-something similar) then you're right.
-
-To compile in the driver, put the files in the correct place and patch in
-the diff.  You will have to re-configure the kernel again before you
-recompile it. 
-
-The driver is not real good at the moment for finding the card.  You can
-'help' it by changing the order of the potential addresses in the structure
-found in the pt_init() function so the address of where the card is is put
-first.
-
-After compiling, you have to get them going, they are pretty well like any
-other net device and just need ifconfig to get them going.
-As an example, here is my /etc/rc.net
---------------------------
-
-#
-# Configure the PackeTwin, port A.
-/sbin/ifconfig pt0a 44.136.8.87 hw ax25 vk2xlz mtu 512 
-/sbin/ifconfig pt0a 44.136.8.87 broadcast 44.136.8.255 netmask 255.255.255.0
-/sbin/route add -net 44.136.8.0 netmask 255.255.255.0 dev pt0a
-/sbin/route add -net 44.0.0.0 netmask 255.0.0.0 gw 44.136.8.68 dev pt0a
-/sbin/route add -net 138.25.16.0 netmask 255.255.240.0 dev pt0a
-/sbin/route add -host 44.136.8.255 dev pt0a
-#
-# Configure the PackeTwin, port B.
-/sbin/ifconfig pt0b 44.136.8.87 hw ax25 vk2xlz-1 mtu 512
-/sbin/ifconfig pt0b 44.136.8.87 broadcast 44.255.255.255 netmask 255.0.0.0
-/sbin/route add -host 44.136.8.216 dev pt0b
-/sbin/route add -host 44.136.8.95  dev pt0b
-/sbin/route add -host 44.255.255.255 dev pt0b
-
-This version of the driver comes under the GNU GPL.  If you have one of my
-previous (non-GPL) versions of the driver, please update to this one.
-
-I hope that this all works well for you.  I would be pleased to hear how
-many people use the driver and if it does its job.
-
-  - Craig vk2xlz <csmall@small.dropbear.id.au>
