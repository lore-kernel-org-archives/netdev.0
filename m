From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: gone with the spring cleanup..
Date: Wed, 13 May 2015 12:38:12 +0200
Message-ID: <20150513103812.GA2136@nanopsycho.mtl.com>
References: <5553158D.7000108@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:34755 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933665AbbEMKiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 06:38:18 -0400
Received: by wicmc15 with SMTP id mc15so75256445wic.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 03:38:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5553158D.7000108@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 13, 2015 at 11:12:45AM CEST, ogerlitz@mellanox.com wrote:
>Hi Scott, Jiri
>
>So, following the spring cleanup, my builder (which turns to have pretty old
>GCC 4.4.6) isn't functional anymore w.r.t net-next... I checked on different
>station and it works on GCC 4.9.2.
>
>I would love us to get this fixed, please let me know if you need more info,
>below is the build verbose command line build error.
>
>Few more pieces of info, changing -std=gnu89to -std=gnu99didn't help. Also
>the command line where it does work (4.9.2) uses -std=gnu89

Looks like the problem might be in named structures which suppose to be
anonymous. Would you try following patch:


diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 3b217b4..12848b3 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -53,12 +53,12 @@ struct switchdev_obj {
 	enum switchdev_obj_id id;
 	enum switchdev_trans trans;
 	union {
-		struct switchdev_obj_vlan {			/* PORT_VLAN */
+		struct{			/* PORT_VLAN */
 			u16 flags;
 			u16 vid_start;
 			u16 vid_end;
 		} vlan;
-		struct switchdev_obj_ipv4_fib {		/* IPV4_FIB */
+		struct {		/* IPV4_FIB */
 			u32 dst;
 			int dst_len;
 			struct fib_info *fi;
