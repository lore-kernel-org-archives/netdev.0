From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN]: Fix SET_VLAN_INGRESS_PRIORITY_CMD ioctl
Date: Sat, 03 Nov 2007 13:24:34 +0100
Message-ID: <472C6882.2070201@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060801030502060407090804"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Doug Kehn <rdkehn@yahoo.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41945 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257AbXKCM2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 08:28:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060801030502060407090804
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Fix a regression in 2.6.23. Candidate for -stable IMO.


--------------060801030502060407090804
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[VLAN]: Fix SET_VLAN_INGRESS_PRIORITY_CMD ioctl

Based on report and patch by Doug Kehn <rdkehn@yahoo.com>:

vconfig returns the following error when attempting to execute the
set_ingress_map command:

vconfig: socket or ioctl error for set_ingress_map: Operation not permitted

In vlan.c, vlan_ioctl_handler for SET_VLAN_INGRESS_PRIORITY_CMD
sets err = -EPERM and calls vlan_dev_set_ingress_priority.
vlan_dev_set_ingress_priority is a void function so err remains
at -EPERM and results in the vconfig error (even though the ingress
map was set).

Fix by setting err = 0 after the vlan_dev_set_ingress_priority call.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit db0d1d928ecdbd1a0c3f6d806c84b4f28a7af0e4
tree 4103b5a3a2dfa353cc4f1617729983650cfdd61a
parent 3743b5898464963ad2b169e3f487205b12fef472
author Patrick McHardy <kaber@trash.net> Fri, 02 Nov 2007 18:59:39 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 02 Nov 2007 18:59:39 +0100

 net/8021q/vlan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 3fe4fc8..1037748 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -747,6 +747,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		vlan_dev_set_ingress_priority(dev,
 					      args.u.skb_priority,
 					      args.vlan_qos);
+		err = 0;
 		break;
 
 	case SET_VLAN_EGRESS_PRIORITY_CMD:

--------------060801030502060407090804--
