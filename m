From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH v3 -mm 5/9] netconsole: Add some useful tips to documentation
Date: Mon, 30 Jul 2007 08:18:30 +0530
Message-ID: <20070730024830.10828.34830.sendpatchset@enigma.security.iitk.ac.in>
References: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:43493 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966092AbXG3CgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 22:36:11 -0400
In-Reply-To: <20070730024741.10828.48209.sendpatchset@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

[5/9] netconsole: Add some useful tips to documentation

Add some useful general-purpose tips. Also suggest solution for the frequent
problem of console loglevel set too low numerically (i.e. for high priority
messages only) on the sender.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Acked-by: Matt Mackall <mpm@selenic.com>

---

 Documentation/networking/netconsole.txt |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
index 1caa6c7..5962f45 100644
--- a/Documentation/networking/netconsole.txt
+++ b/Documentation/networking/netconsole.txt
@@ -44,11 +44,36 @@ WARNING: the default target ethernet setting uses the broadcast
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
+printing all messages from the sender, it is likely that you have set
+the "console_loglevel" parameter (on the sender) to only send high
+priority messages to the console. You can change this at runtime using:
+
+ dmesg -n 8
+
+or by specifying "debug" on the kernel command line at boot, to send
+all kernel messages to the console. A specific value for this parameter
+can also be set using the "loglevel" kernel boot option. See the
+dmesg(8) man page and Documentation/kernel-parameters.txt for details.
+
 Netconsole was designed to be as instantaneous as possible, to
 enable the logging of even the most critical kernel bugs. It works
 from IRQ contexts as well, and does not enable interrupts while
