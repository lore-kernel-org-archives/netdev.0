From: Ichiro Suzuki <isuzuki@miraclelinux.com>
Subject: Question about VLAN + checksum offloading
Date: Fri, 16 May 2008 16:52:54 +0900
Message-ID: <1210924374.5136.94.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-py9tkLNFFM5oi9V+1Tq0"
Cc: Naohiro Ooiwa <nooiwa@miraclelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:53549 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbYEPIYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 04:24:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-py9tkLNFFM5oi9V+1Tq0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

  Looking in oprofile log, I observed
	csum_partial_copy_generic()
is invoked for a 802.1Q VLAN device created on e1000,
This suggests checksum offloading is not in effect.
The offloading works fine when e1000 is used directly.
Attached one liner patch fixes this. But, it seems
too obvious to be a correct answer.

  My questions are,
o Is it right to expect checksum offloading should work
 on VLAN devices?
o If so, is there any mechanism to propagate
 real_dev->features flags in vlan.c?
o If such mechanism doesn't exist, is my patch reasonable?
.

  The machine arch is x86_64.  I got similar results
on an ancient 2.6.9 kernel and on the latest 2.6.25.

Thanks in advance,
----------------------------------------------
Ichiro Suzuki       <isuzuki@miraclelinux.com>
Miracle Linux Corp., Advanced Technology Group
----------------------------------------------


--=-py9tkLNFFM5oi9V+1Tq0
Content-Disposition: attachment; filename=linux-2.6.25_vlan.patch
Content-Type: text/x-patch; name=linux-2.6.25_vlan.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2.6.25.orig/net/8021q/vlan.c	2008-04-17 11:49:44.000000000 +0900
+++ linux-2.6.25/net/8021q/vlan.c	2008-05-16 15:03:03.000000000 +0900
@@ -333,6 +333,9 @@ static int register_vlan_device(struct n
 	 */
 	new_dev->mtu = real_dev->mtu;
 
+	/* features setting */
+	new_dev->features = real_dev->features;
+
 	vlan_dev_info(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
 	vlan_dev_info(new_dev)->real_dev = real_dev;
 	vlan_dev_info(new_dev)->dent = NULL;

--=-py9tkLNFFM5oi9V+1Tq0--

