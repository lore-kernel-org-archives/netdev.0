From: Ben Greear <greearb@candelatech.com>
Subject: VLAN patch:  Export symbols as non GPL symbols.
Date: Mon, 26 Jan 2009 09:01:46 -0800
Message-ID: <497DEC7A.1040405@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090806080600010205030807"
To: Patrick McHardy <kaber@trash.net>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34680 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbZAZRBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 12:01:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090806080600010205030807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In previous kernels, any kernel module could get access to the 
'real-device' and the
VLAN-ID for a particular VLAN.  In more recent kernels, the code was 
restructured
such that this is hard to do without accessing private .h files for any 
module that cannot
use GPL-only symbols.

Attached is a patch to once again allow non-GPL modules the ability to 
access the
real-device and VLAN id for VLANs.  This patch is against 2.6.29-rc2.

Signed-Off-By:  Ben Greear<greearb@candelatech.com>

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com



--------------090806080600010205030807
Content-Type: text/x-patch;
 name="vlan_export.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan_export.patch"

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 6c13239..e9db889 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -62,13 +62,13 @@ struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	return vlan_dev_info(dev)->real_dev;
 }
-EXPORT_SYMBOL_GPL(vlan_dev_real_dev);
+EXPORT_SYMBOL(vlan_dev_real_dev);
 
 u16 vlan_dev_vlan_id(const struct net_device *dev)
 {
 	return vlan_dev_info(dev)->vlan_id;
 }
-EXPORT_SYMBOL_GPL(vlan_dev_vlan_id);
+EXPORT_SYMBOL(vlan_dev_vlan_id);
 
 static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 			   unsigned int vlan_tci, struct sk_buff *skb)

--------------090806080600010205030807--
