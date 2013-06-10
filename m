From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 04/12] vxlan: send notification when MAC migrates
Date: Mon, 10 Jun 2013 13:24:52 -0700
Message-ID: <20130610132452.0254d164@nehalam.linuxnetplumber.net>
References: <20130610200524.721617349@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:41522 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657Ab3FJU0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:26:00 -0400
Received: by mail-pd0-f170.google.com with SMTP id x11so2050286pdj.29
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:25:59 -0700 (PDT)
In-Reply-To: <20130610200524.721617349@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When learned entry migrates to another IP send a notification
that entry has changed.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/vxlan.c	2013-06-10 12:19:58.398104802 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 12:19:59.002097934 -0700
@@ -629,6 +629,7 @@ static bool vxlan_snoop(struct net_devic
 
 		f->remote.remote_ip = src_ip;
 		f->updated = jiffies;
+		vxlan_fdb_notify(vxlan, f, RTM_NEWNEIGH);
 	} else {
 		/* learned new entry */
 		spin_lock(&vxlan->hash_lock);
