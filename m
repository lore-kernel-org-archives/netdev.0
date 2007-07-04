From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH -mm 6/9] netconsole: Update documentation for multiple target support
Date: Wed, 04 Jul 2007 16:38:09 +0530
Message-ID: <20070704110809.28520.1141.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:57161 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761448AbXGDLIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:02 -0400
In-Reply-To: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[6/9] netconsole: Update documentation for multiple target support

... and add a few useful general purpose tips as well while we're at it.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

---

 Documentation/networking/netconsole.txt |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

---

diff -ruNp a/Documentation/networking/netconsole.txt b/Documentation/networking/netconsole.txt
--- a/Documentation/networking/netconsole.txt	2007-04-26 08:38:32.000000000 +0530
+++ b/Documentation/networking/netconsole.txt	2007-07-02 11:44:53.000000000 +0530
@@ -34,6 +34,12 @@ Examples:
 
  insmod netconsole netconsole=@/,@10.0.0.2/
 
+It also supports logging to multiple remote agents by specifying
+parameters for the multiple agents separated by semicolons and the
+complete string enclosed in "quotes", thusly:
+
+modprobe netconsole netconsole="@/,@10.0.0.2/;@/eth1,6892@10.0.0.3/"
+
 Built-in netconsole starts immediately after the TCP stack is
 initialized and attempts to bring up the supplied dev at the supplied
 address.
@@ -44,6 +50,18 @@ WARNING: the default target ethernet set
 ethernet address to send packets, which can cause increased load on
 other systems on the same ethernet segment.
 
+TIP: some LAN switches may be configured to suppress ethernet broadcasts
+so it is advised to explicitly specify the remote agents' MAC addresses
+from the config parameters passed to netconsole.
+
+TIP: to find out the MAC address of 10.0.0.2, you may try using:
+ping -c 1 10.0.0.2 ; /sbin/arp -n | grep 10.0.0.2
+
+TIP: in case the remote logging agent is on a separate LAN subnet than
+the sender, it is suggested to try specifying the default gateway's
+(you may use /sbin/route -n to find out) MAC address as the remote MAC
+address instead.
+
 NOTE: the network device (eth1 in the above case) can run any kind
 of other network traffic, netconsole is not intrusive. Netconsole
 might cause slight delays in other traffic if the volume of kernel
