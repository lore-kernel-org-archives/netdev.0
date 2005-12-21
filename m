From: Mika Kukkonen <mikukkon@iki.fi>
Subject: [PATCH] VLAN: Add two missing checks to vlan_ioctl_handler()
Date: Wed, 21 Dec 2005 22:50:15 +0200
Message-ID: <20051221205015.GC24213@localhost.localdomain>
Reply-To: mikukkon@iki.fi
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751169AbVLUUuo@vger.kernel.org>
To: vlan@candelatech.com, netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In vlan_ioctl_handler() the code misses couple checks for
error return values.

Signed-of-by: Mika Kukkonen <mikukkon@iki.fi>

---

 net/8021q/vlan.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 91e412b..67465b6 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -753,6 +753,8 @@ static int vlan_ioctl_handler(void __use
 		break;
 	case GET_VLAN_REALDEV_NAME_CMD:
 		err = vlan_dev_get_realdev_name(args.device1, args.u.device2);
+		if (err)
+			goto out;
 		if (copy_to_user(arg, &args,
 				 sizeof(struct vlan_ioctl_args))) {
 			err = -EFAULT;
@@ -761,6 +763,8 @@ static int vlan_ioctl_handler(void __use
 
 	case GET_VLAN_VID_CMD:
 		err = vlan_dev_get_vid(args.device1, &vid);
+		if (err)
+			goto out;
 		args.u.VID = vid;
 		if (copy_to_user(arg, &args,
 				 sizeof(struct vlan_ioctl_args))) {
@@ -774,7 +778,7 @@ static int vlan_ioctl_handler(void __use
 			__FUNCTION__, args.cmd);
 		return -EINVAL;
 	};
-
+out:
 	return err;
 }
 
