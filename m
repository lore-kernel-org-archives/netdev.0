From: akpm@linux-foundation.org
Subject: [patch 22/28] netconsole: Add some useful tips to documentation
Date: Fri, 10 Aug 2007 14:12:05 -0700
Message-ID: <200708102112.l7ALC5fF009445@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	satyam@infradead.org, k-keiichi@bx.jp.nec.com, mpm@selenic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53125 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756133AbXHJVQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>

Based upon initial work by Keiichi Kii <k-keiichi@bx.jp.nec.com>.

Add some useful general-purpose tips.  Also suggest solution for the frequent
problem of console loglevel set too low numerically (i.e.  for high priority
messages only) on the sender.

Signed-off-by: Satyam Sharma <satyam@infradead.org>
Acked-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Acked-by: Matt Mackall <mpm@selenic.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/networking/netconsole.txt |   25 ++++++++++++++++++++++
 1 files changed, 25 insertions(+)

diff -puN Documentation/networking/netconsole.txt~netconsole-add-some-useful-tips-to-documentation Documentation/networking/netconsole.txt
--- a/Documentation/networking/netconsole.txt~netconsole-add-some-useful-tips-to-documentation
+++ a/Documentation/networking/netconsole.txt
@@ -44,11 +44,36 @@ WARNING: the default target ethernet set
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
_
