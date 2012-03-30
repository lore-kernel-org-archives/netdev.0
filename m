From: Ulrich Drepper <drepper@gmail.com>
Subject: sendmmsg: put_user vs __put_user
Date: Fri, 30 Mar 2012 09:36:11 -0400
Message-ID: <CAOPLpQf2bmj+i_zYtsS8JNzTDuBxCO5ByNRRqwv0kxaDBFdezg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:53683 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932511Ab2C3Ngf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 09:36:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shouldn't the compat code in the sendmmsg implementation use the same
code as the normal code?  In which case you probably want something
like this:

diff --git a/net/socket.c b/net/socket.c
index 484cc69..ff40409 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2064,7 +2064,7 @@ int __sys_sendmmsg(int fd, struct mmsghdr __user
*mmsg, unsigned int vlen,
                                            &msg_sys, flags, &used_address);
                        if (err < 0)
                                break;
-                       err = __put_user(err, &compat_entry->msg_len);
+                       err = put_user(err, &compat_entry->msg_len);
                        ++compat_entry;
                } else {
                        err = __sys_sendmsg(sock, (struct msghdr __user *)entry,
