From: Loganaden Velvindron <logan@elandsys.com>
Subject: [PATCH net-next ] net: ipv4: memset addr before calling
 copy_to_user()
Date: Sun, 8 Nov 2015 22:52:36 -0800
Message-ID: <20151109065236.GA2271@mx.elandsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.qubic.net ([208.69.177.116]:55282 "EHLO mx.elandsys.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbbKIGwj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2015 01:52:39 -0500
Received: from mx.elandsys.com (IDENT:logan@localhost [127.0.0.1])
	by mx.elandsys.com (8.14.5/8.14.5) with ESMTP id tA96qbx7012084
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 8 Nov 2015 22:52:38 -0800 (PST)
Received: (from logan@localhost)
	by mx.elandsys.com (8.14.5/8.14.5/Submit) id tA96qaaC018261
	for netdev@vger.kernel.org; Sun, 8 Nov 2015 22:52:36 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

zero addr before calling copy_to_user()
 
Signed-off-by: Loganaden Velvindron <logan@elandsys.com>
---
 net/ipv4/ip_sockglue.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index c3c359a..d7a5a8b 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1373,6 +1373,7 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_MULTICAST_IF:
 	{
 		struct in_addr addr;
+		memset(&addr, 0, sizeof(addr));
 		len = min_t(unsigned int, len, sizeof(struct in_addr));
 		addr.s_addr = inet->mc_addr;
 		release_sock(sk);
-- 
2.6.2
