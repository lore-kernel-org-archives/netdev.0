From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH v2 (updated) -mm 4/9] netconsole: Add some useful tips to documentation
Date: Wed, 11 Jul 2007 03:49:29 +0530
Message-ID: <20070710221929.3414.80246.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:57889 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbXGKEyK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2007 00:54:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[4/9 (updated)] netconsole: Add some useful tips to documentation

Add some useful general-purpose tips. Also suggest solution for the frequent
problem of console_loglevel set too low numerically (i.e. for high priority
messages only) on the sender.

Cc: Matt Mackall <mpm@selenic.com>
Cc: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>

---

 Documentation/networking/netconsole.txt |   24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

---

diff -ruNp a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
--- a/Documentation/networking/netconsole.txt	2007-04-26 08:38:32.000000000 +0530
+++ b/Documentation/networking/netconsole.txt	2007-07-11 03:11:08.000000000 +0530
@@ -44,11 +44,35 @@ WARNING: the default target ethernet set
 ethernet address to send packets, which can cause increased load on
 other systems on the same ethernet segment.
 
+TIP: some LAN switches may be configured to suppress ethernet broadcasts
+so it is advised to explicitly specify the remote agents' MAC addresses
+from the config parameters passed to netconsole.
+
+TIP: to find out the MAC address of, say, 10.0.0.2, you may try using:
+
+ ping -c 1 10.0.0.2 ; /sbin/arp -n | grep 10.0.0.2
+
+TIP: in case the remote logging agent is on a separate LAN subnet than
+the sender, it is suggested to try specifying the MAC address of the
+default gateway (you may use /sbin/route -n to find it out) as the
+remote MAC address instead.
+
 NOTE: the network device (eth1 in the above case) can run any kind
 of other network traffic, netconsole is not intrusive. Netconsole
 might cause slight delays in other traffic if the volume of kernel
 messages is high, but should have no other impact.
 
+NOTE: if you find that the remote logging agent is not receiving or
+printing all messages from the sender, it is likely that you have set the
+"console_loglevel" parameter (on the sender) to only send high priority
+messages to the console. You can change this at runtime by updating
+/proc/sys/kernel/printk appropriately, say by:
+
+ echo 9 > /proc/sys/kernel/printk
+
+which would send all kernel messages to the console. Refer the proc(5)
+man page for more details.
+
 Netconsole was designed to be as instantaneous as possible, to
 enable the logging of even the most critical kernel bugs. It works
 from IRQ contexts as well, and does not enable interrupts while
