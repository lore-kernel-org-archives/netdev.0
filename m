From: Patrick McHardy <kaber@trash.net>
Subject: netfilter: ctnetlink: fix GFP_KERNEL allocation under spinlock
Date: Wed, 26 Nov 2008 12:23:08 +0100
Message-ID: <492D319C.4060008@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020606090005080809050303"
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020606090005080809050303
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

This patch for 2.6.28 fixes a GFP_KERNEL allocation under spinlock
in ctnetlink that was missed in the conntrack creation race fix.

Please apply, thanks.

--------------020606090005080809050303
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 49a12376315f651decfa67c07041e2d0c2e04968
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Nov 26 12:16:50 2008 +0100

    netfilter: ctnetlink: fix GFP_KERNEL allocation under spinlock
    
    The previous fix for the conntrack creation race (netfilter: ctnetlink:
    fix conntrack creation race) missed a GFP_KERNEL allocation that is
    now performed while holding a spinlock. Switch to GFP_ATOMIC.
    
    Reported-and-tested-by: Zoltan Borbely <bozo@andrews.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 3b009a3..5f4a651 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1138,7 +1138,7 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 		}
 	}
 
-	nf_ct_acct_ext_add(ct, GFP_KERNEL);
+	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
 
 #if defined(CONFIG_NF_CONNTRACK_MARK)
 	if (cda[CTA_MARK])

--------------020606090005080809050303--
