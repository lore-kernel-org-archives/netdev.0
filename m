From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] vxlan: put UDP socket in correct namespace
Date: Mon, 1 Oct 2012 17:51:07 -0700
Message-ID: <20121001175107.0ec2931c@nehalam.linuxnetplumber.net>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
	<87fw5xeryf.fsf@xmission.com>
	<20121001155702.5b5e2188@nehalam.linuxnetplumber.net>
	<87y5jpdbzo.fsf@xmission.com>
	<20121001163226.3873ca58@nehalam.linuxnetplumber.net>
	<871uhhd82p.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48074 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752350Ab2JBAvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 20:51:42 -0400
In-Reply-To: <871uhhd82p.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move vxlan UDP socket to correct network namespace

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/vxlan.c	2012-10-01 17:18:30.776513263 -0700
+++ b/drivers/net/vxlan.c	2012-10-01 17:42:28.340411631 -0700
@@ -1136,6 +1136,9 @@ static __net_init int vxlan_init_net(str
 		pr_debug("UDP socket create failed\n");
 		return rc;
 	}
+	/* Put in proper namespace */
+	sk = vn->sock->sk;
+	sk_change_net(sk, net);
 
 	vxlan_addr.sin_port = htons(vxlan_port);
 
@@ -1150,7 +1153,6 @@ static __net_init int vxlan_init_net(str
 	}
 
 	/* Disable multicast loopback */
-	sk = vn->sock->sk;
 	inet_sk(sk)->mc_loop = 0;
 
 	/* Mark socket as an encapsulation socket. */
