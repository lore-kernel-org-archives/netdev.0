From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 09/18]: Remove non-implemented ioctls
Date: Sun, 20 Jan 2008 18:11:29 +0100 (MET)
Message-ID: <20080120171129.7980.7502.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62357 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754476AbYATRLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:30 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Remove non-implemented ioctls

The GET_VLAN_INGRESS_PRIORITY_CMD/GET_VLAN_EGRESS_PRIORITY_CMD ioctls are
not implemented and won't be, new functionality will be added to the netlink
interface. Remove the code and make the ioctl handler return -EOPNOTSUPP
for unknown commands instead of -EINVAL.

Also remove a comment about passing unknown commands to the underlying
device, that doesn't make any sense since its a VLAN specific ioctl and
if its not implemented here, its implemented nowhere.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8798cc926478d29231ad48d5e0ff31e434660ddb
tree bd5a582834f284db01ad92e19153ad307a425510
parent 7d925b47858e2f18fd474c673a0a75a0cfd00ebf
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100

 net/8021q/vlan.c |   23 +----------------------
 1 files changed, 1 insertions(+), 22 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 6edd191..69a9e02 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -688,26 +688,6 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		err = unregister_vlan_device(dev);
 		break;
 
-	case GET_VLAN_INGRESS_PRIORITY_CMD:
-		/* TODO:  Implement
-		   err = vlan_dev_get_ingress_priority(args);
-		   if (copy_to_user((void*)arg, &args,
-			sizeof(struct vlan_ioctl_args))) {
-			err = -EFAULT;
-		   }
-		*/
-		err = -EINVAL;
-		break;
-	case GET_VLAN_EGRESS_PRIORITY_CMD:
-		/* TODO:  Implement
-		   err = vlan_dev_get_egress_priority(args.device1, &(args.args);
-		   if (copy_to_user((void*)arg, &args,
-			sizeof(struct vlan_ioctl_args))) {
-			err = -EFAULT;
-		   }
-		*/
-		err = -EINVAL;
-		break;
 	case GET_VLAN_REALDEV_NAME_CMD:
 		err = 0;
 		vlan_dev_get_realdev_name(dev, args.u.device2);
@@ -728,8 +708,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		break;
 
 	default:
-		/* pass on to underlying device instead?? */
-		err = -EINVAL;
+		err = -EOPNOTSUPP;
 		break;
 	}
 out:
