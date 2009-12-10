From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH 2/2] net: use compat helper functions in compat_sys_recvmmsg
Date: Thu, 10 Dec 2009 07:59:15 +0100
Message-ID: <20091210065914.GB4144@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:59227 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbZLJG7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 01:59:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Use (get|put)_compat_timespec helper functions to simplify the code.

Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 net/compat.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

Index: linux-2.6/net/compat.c
===================================================================
--- linux-2.6.orig/net/compat.c
+++ linux-2.6/net/compat.c
@@ -763,15 +763,12 @@ asmlinkage long compat_sys_recvmmsg(int 
 		return __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
 				      flags | MSG_CMSG_COMPAT, NULL);
 
-	if (get_user(ktspec.tv_sec, &timeout->tv_sec) ||
-	    get_user(ktspec.tv_nsec, &timeout->tv_nsec))
+	if (get_compat_timespec(&ktspec, timeout))
 		return -EFAULT;
 
 	datagrams = __sys_recvmmsg(fd, (struct mmsghdr __user *)mmsg, vlen,
 				   flags | MSG_CMSG_COMPAT, &ktspec);
-	if (datagrams > 0 &&
-	    (put_user(ktspec.tv_sec, &timeout->tv_sec) ||
-	     put_user(ktspec.tv_nsec, &timeout->tv_nsec)))
+	if (datagrams > 0 && put_compat_timespec(&ktspec, timeout))
 		datagrams = -EFAULT;
 
 	return datagrams;
