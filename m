From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net 0/2] Fixes for SO_REUSEPORT and mixed v4/v6 sockets
Date: Tue, 12 Apr 2016 13:11:24 -0400
Message-ID: <1460481086-12982-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:34059 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965072AbcDLRLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 13:11:31 -0400
Received: by mail-qk0-f179.google.com with SMTP id r184so8961823qkc.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 10:11:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Recent changes to the datastructures associated with SO_REUSEPORT broke
an existing behavior when equivalent SO_REUSEPORT sockets are created
using both AF_INET and AF_INET6.  This patch series restores the previous
behavior and includes a test to validate it.

This series should be a trivial merge to stable kernels (if deemed
necessary), but will have conflicts in net-next.  The following patches
recently replaced the use of hlist_nulls with hlists for UDP and TCP
socket lists:
ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")

If this series is accepted, I will send an RFC for the net-next change
to assist with the merge.

Craig Gallek (2):
  soreuseport: fix ordering for mixed v4/v6 sockets
  soreuseport: test mixed v4/v6 sockets

 include/linux/rculist_nulls.h                     |  39 ++++
 include/net/sock.h                                |   6 +-
 net/ipv4/udp.c                                    |   9 +-
 tools/testing/selftests/net/.gitignore            |   1 +
 tools/testing/selftests/net/Makefile              |   2 +-
 tools/testing/selftests/net/reuseport_dualstack.c | 208 ++++++++++++++++++++++
 6 files changed, 261 insertions(+), 4 deletions(-)
 create mode 100644 tools/testing/selftests/net/reuseport_dualstack.c

-- 
2.8.0.rc3.226.g39d4020
