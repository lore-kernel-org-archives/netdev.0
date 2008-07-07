From: Richard Kennedy <richard@rsk.demon.co.uk>
Subject: [PATCH]  net: remove padding from struct socket on 64bit &
	increase objects/cache
Date: Mon, 07 Jul 2008 12:58:10 +0100
Message-ID: <1215431890.3101.5.camel@castor.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-32.mail.demon.net ([194.217.242.90]:1565 "EHLO
	anchor-post-32.mail.demon.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752383AbYGGL6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 07:58:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove padding from struct socket reducing its size by 8 bytes.
    
This allows more objects/cache in sock_inode_cache
12 objects/cache when cacheline size is 128 (generic x86_64)
    
Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
----

compiled & booted on 2.6.26-rc8

Richard


diff --git a/include/linux/net.h b/include/linux/net.h
index 71f7dd5..150a48c 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -106,23 +106,23 @@ enum sock_shutdown_cmd {
 /**
  *  struct socket - general BSD socket
  *  @state: socket state (%SS_CONNECTED, etc)
+ *  @type: socket type (%SOCK_STREAM, etc)
  *  @flags: socket flags (%SOCK_ASYNC_NOSPACE, etc)
  *  @ops: protocol specific socket operations
  *  @fasync_list: Asynchronous wake up list
  *  @file: File back pointer for gc
  *  @sk: internal networking protocol agnostic socket representation
  *  @wait: wait queue for several uses
- *  @type: socket type (%SOCK_STREAM, etc)
  */
 struct socket {
 	socket_state		state;
+	short			type;
 	unsigned long		flags;
 	const struct proto_ops	*ops;
 	struct fasync_struct	*fasync_list;
 	struct file		*file;
 	struct sock		*sk;
 	wait_queue_head_t	wait;
-	short			type;
 };
 
 struct vm_area_struct;


