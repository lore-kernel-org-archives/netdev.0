From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/2] net: diag: fix a potential security issue
Date: Thu, 19 Oct 2017 15:32:23 +0800
Message-ID: <cover.1508398111.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:45052 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751724AbdJSHce (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 03:32:34 -0400
Received: by mail-pg0-f67.google.com with SMTP id j3so6432240pga.1
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 00:32:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to void the potential security issue that the family
or protocol modules are autoloaded when requesting _diag module by
not requesting _diag module if the family or protocol is not added
or registered in sock_diag and inet_diag.

As the repost of the patch '[PATCH net] sock_diag: request _diag
module only when the family or proto has been registered', this
patchset fixes the compiling errors when INET is not set, and
also split into two patches to make it clear to review.

Xin Long (2):
  sock_diag: request _diag module only when the family has been
    registered
  inet_diag: request _diag module only when the proto has been
    registered

 include/linux/net.h    |  1 +
 include/net/protocol.h |  1 +
 net/core/sock_diag.c   | 21 +++++++++++++--------
 net/ipv4/inet_diag.c   |  3 ++-
 net/ipv4/protocol.c    |  6 ++++++
 net/socket.c           |  5 +++++
 6 files changed, 28 insertions(+), 9 deletions(-)

-- 
2.1.0
