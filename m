From: Hua Zhong <hzhong@gmail.com>
Subject: [PATCH] sockfd_lookup_light() returns random error for -EBADFD
Date: Wed, 19 Apr 2006 12:01:06 -0700
Message-ID: <444688F2.5060909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.207]:27009 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1751177AbWDSTCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 15:02:03 -0400
Received: by nz-out-0102.google.com with SMTP id o37so1143187nzf
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2006 12:02:02 -0700 (PDT)
To: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, torvalds@osdl.org, davem@davemloft.net,
	akpm@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This applies to 2.6.17-rc2.

There is a missing initialization of err in sockfd_lookup_light() that could return random error for an invalid file handle.

Signed-off-by: Hua Zhong <hzhong@gmail.com>

diff --git a/net/socket.c b/net/socket.c
index 23898f4..0ce12df 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -490,6 +490,7 @@ static struct socket *sockfd_lookup_ligh
 	struct file *file;
 	struct socket *sock;
 
+	*err = -EBADF;
 	file = fget_light(fd, fput_needed);
 	if (file) {
 		sock = sock_from_file(file, err);
