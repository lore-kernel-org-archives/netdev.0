From: Patrick McHardy <kaber@trash.net>
Subject: [NET]: Messed multicast lists after dev_mc_sync/unsync
Date: Tue, 19 Feb 2008 15:56:59 +0100
Message-ID: <47BAEE3B.7020502@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000200030504080205070601"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:58556 "EHLO
	viefep19-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753300AbYBSO5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 09:57:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000200030504080205070601
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------000200030504080205070601
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 6548b91f39381b2c5f02f99c14734546354bff89
Author: Jorge Boncompte [DTI2] <jorge@dti2.net>
Date:   Mon Feb 18 16:02:01 2008 +0100

    [NET]: Messed multicast lists after dev_mc_sync/unsync
    
    Commit a0a400d79e3dd7843e7e81baa3ef2957bdc292d0 from you
    introduced a new field "da_synced" to struct dev_addr_list that is
    not properly initialized to 0. So when any of the current users (8021q,
    macvlan, mac80211) calls dev_mc_sync/unsync they mess the address
    list for both devices.
    
    The attached patch fixed it for me and avoid future problems.
    
    Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 6cfc123..9516105 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2900,7 +2900,7 @@ int __dev_addr_add(struct dev_addr_list **list, int *count,
 		}
 	}
 
-	da = kmalloc(sizeof(*da), GFP_ATOMIC);
+	da = kzalloc(sizeof(*da), GFP_ATOMIC);
 	if (da == NULL)
 		return -ENOMEM;
 	memcpy(da->da_addr, addr, alen);

--------------000200030504080205070601--
