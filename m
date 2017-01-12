From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] secure_seq: fix sparse errors
Date: Wed, 11 Jan 2017 18:10:37 -0800
Message-ID: <1484187037.15816.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33703 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751168AbdALCQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 21:16:56 -0500
Received: by mail-pf0-f194.google.com with SMTP id 127so950262pfg.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 18:16:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fixes following warnings :

net/core/secure_seq.c:125:28: warning: incorrect type in argument 1
(different base types)
net/core/secure_seq.c:125:28:    expected unsigned int const [unsigned]
[usertype] a
net/core/secure_seq.c:125:28:    got restricted __be32 [usertype] saddr
net/core/secure_seq.c:125:35: warning: incorrect type in argument 2
(different base types)
net/core/secure_seq.c:125:35:    expected unsigned int const [unsigned]
[usertype] b
net/core/secure_seq.c:125:35:    got restricted __be32 [usertype] daddr
net/core/secure_seq.c:125:43: warning: cast from restricted __be16
net/core/secure_seq.c:125:61: warning: restricted __be16 degrades to
integer


Fixes: 7cd23e5300c1 ("secure_seq: use SipHash in place of MD5")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/secure_seq.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 3a9fcec94ace21238c0d6cd6d9997678e0623ab9..758f140b6bedc51669fed973b39ee317c2bf1570 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -122,7 +122,9 @@ u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
 {
 	u64 seq;
 	net_secret_init();
-	seq = siphash_3u32(saddr, daddr, (u32)sport << 16 | dport, &net_secret);
+	seq = siphash_3u32((__force u32)saddr, (__force u32)daddr,
+			   (__force u32)sport << 16 | (__force u32)dport,
+			   &net_secret);
 	seq += ktime_get_real_ns();
 	seq &= (1ull << 48) - 1;
 	return seq;
