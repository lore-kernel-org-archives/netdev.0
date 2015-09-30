From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix tcp_v6_md5_do_lookup prototype
Date: Tue, 29 Sep 2015 21:24:05 -0700
Message-ID: <1443587045.32531.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201509301242.V51qs4FL%fengguang.wu@intel.com>
	 <1443586228.32531.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150929.211243.946334552303109593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, edumazet@google.com, kbuild-all@01.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33781 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbbI3EYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:24:07 -0400
Received: by pacex6 with SMTP id ex6so27100129pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 21:24:06 -0700 (PDT)
In-Reply-To: <20150929.211243.946334552303109593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_v6_md5_do_lookup() now takes a const socket, even if
CONFIG_TCP_MD5SIG is not set.

Fixes: b83e3deb974c ("tcp: md5: constify tcp_md5_do_lookup() socket argument")
From: Eric Dumazet <edumazet@google.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
---
 net/ipv6/tcp_ipv6.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 0ac64f47f8821ce7da103ecc7391ba7e..2ae95e1d03e1c0d5149c9f6fa7cf94d9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -82,7 +82,7 @@ static const struct inet_connection_sock_af_ops ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_specific;
 static const struct tcp_sock_af_ops tcp_sock_ipv6_mapped_specific;
 #else
-static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(struct sock *sk,
+static struct tcp_md5sig_key *tcp_v6_md5_do_lookup(const struct sock *sk,
 						   const struct in6_addr *addr)
 {
 	return NULL;
