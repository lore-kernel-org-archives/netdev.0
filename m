From: Phil Karn <karn@ka9q.net>
Subject: Off-by-one error in net/8021q/vlan.c
Date: Wed, 16 Feb 2011 02:58:23 -0800
Message-ID: <4D5BADCF.5000804@ka9q.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:63536 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755806Ab1BPK62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 05:58:28 -0500
Received: by pxi15 with SMTP id 15so176677pxi.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 02:58:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The range check on vlan_id in register_vlan_device is off by one, and it
prevents the creation of a vlan interface for vlan ID 4095. (OSX allows
this, I checked.)

Here's the trivial patch:

--- linux-2.6.37/net/8021q/vlan.c~	2011-01-04 16:50:19.000000000 -0800
+++ linux-2.6.37/net/8021q/vlan.c	2011-02-16 02:43:13.988812958 -0800
@@ -239,7 +239,7 @@
 	char name[IFNAMSIZ];
 	int err;

-	if (vlan_id >= VLAN_VID_MASK)
+	if (vlan_id > VLAN_VID_MASK)
 		return -ERANGE;

 	err = vlan_check_real_dev(real_dev, vlan_id);
