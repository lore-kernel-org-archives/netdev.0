From: "Jonas Danielsson" <the.sator@gmail.com>
Subject: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0 (was: Strange behavior in arp probe reply, bug or feature?)
Date: Thu, 15 Nov 2007 12:40:22 +0100
Message-ID: <cac0ab7d0711150340p58eda94ah92894072ba328205@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1765490AbXKOLki@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix arp reply when received arp probe with sender ip 0.

Can't find any ground in RFC2131 to send a non-valid arp-reply in
the special case of sender ip being set to 0.

- Bug fix for arp handling when sender ip is set to 0.
Send a correct arp reply instead of one with sender ip and sender
hardware adress in target fields.

Now sends target ip and target hw as received in arp probe.

Signed-off-by: Jonas Danielsson <the.sator@gmail.com>

---
arp.c |    3 ++-
1 file changed, 2 insertions(+), 1 deletion(-)

Index: arp.c
===================================================================
RCS file: /usr/local/cvs/linux/os/linux-2.6/net/ipv4/arp.c,v
retrieving revision 1.22
diff -u -w -r1.22 arp.c
--- arp.c	13 Oct 2006 12:45:47 -0000	1.22
+++ arp.c	15 Nov 2007 10:34:44 -0000
@@ -827,7 +827,8 @@
 		if (arp->ar_op == htons(ARPOP_REQUEST) &&
 		    inet_addr_type(tip) == RTN_LOCAL &&
 		    !arp_ignore(in_dev,dev,sip,tip))
-			arp_send(ARPOP_REPLY,ETH_P_ARP,tip,dev,tip,sha,dev->dev_addr,dev->dev_addr);
+			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
+				 dev->dev_addr, sha);
 		goto out;
 	}
