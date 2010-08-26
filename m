From: Bernard F6BVP <f6bvp@free.fr>
Subject: [PATCH] [ROSE] rose node number was never decreased
Date: Fri, 27 Aug 2010 00:15:01 +0200
Message-ID: <4C76E765.9020201@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030809080406030508080107"
Cc: davem@davemloft.net, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, bpidoux@free.fr
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030809080406030508080107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

When a ROSE node was deleted, node number was not
decremented and addr kept going up when a new node
was added.

/proc/net/rose_neigh
addr  callsign  dev  count use mode restart  t0  tf digipeaters
00007 F5KBW-9   ax0      1   0  DTE      no   0   0
00006 F6BVP-11  ax0      2   0  DTE      no   0   0
00005 F6BVP-9   ax0      2   0  DTE      no   0   0
00001 RSLOOP-0  ???      0   0  DCE     yes   0   0

With this patch, rose node number is correctly decreased
when nodes are deleted and new ones added :

/proc/net/rose_neigh
addr  callsign  dev  count use mode restart  t0  tf digipeaters
00004 F5KBW-9   ax0      1   0  DTE      no   0   0
00003 F6BVP-11  ax0      2   0  DTE      no   0   0
00002 F6BVP-9   ax0      2   0  DTE      no   0   0
00001 RSLOOP-0  ???      0   0  DCE     yes   0   0

Signed-off-by: Bernard Pidoux <f6bvp@free.fr>




--------------030809080406030508080107
Content-Type: text/x-patch;
 name="rose_route.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rose_route.patch"

--- a/net/rose/rose_route.c	2010-08-13 22:44:56.000000000 +0200
+++ b/net/rose/rose_route.c	2010-08-26 15:11:13.000000000 +0200
@@ -240,6 +240,7 @@
 			ax25_cb_put(rose_neigh->ax25);
 		kfree(rose_neigh->digipeat);
 		kfree(rose_neigh);
+		rose_neigh_no--;
 		return;
 	}
 
@@ -250,6 +251,7 @@
 				ax25_cb_put(rose_neigh->ax25);
 			kfree(rose_neigh->digipeat);
 			kfree(rose_neigh);
+			rose_neigh_no--;
 			return;
 		}
 


--------------030809080406030508080107--
