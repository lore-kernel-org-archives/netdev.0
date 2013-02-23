From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 0/2] net: sock_diag fixes
Date: Sat, 23 Feb 2013 12:13:46 +0100
Message-ID: <1361618028-9024-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:43872 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757040Ab3BWLOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 06:14:11 -0500
Received: by mail-bk0-f45.google.com with SMTP id i18so642823bkv.32
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2013 03:14:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

this small series fixes an exploitable bug in sock_diag. An unprivileged
user can send us a netlink message resulting in an out-of-bounds access
that allows userland to take over control while in kernel mode.

The first patch fixes the bug and should be pushed to stable. The second
one is an attempt to cleanup the sock_diag_handlers[] access mess in
__sock_diag_rcv_msg.

Please apply!


Mathias Krause (2):
  sock_diag: Fix out-of-bounds access to sock_diag_handlers[]
  sock_diag: Simplify sock_diag_handlers[] handling in
    __sock_diag_rcv_msg

 net/core/sock_diag.c |   27 ++++++++++-----------------
 1 file changed, 10 insertions(+), 17 deletions(-)

-- 
1.7.10.4
