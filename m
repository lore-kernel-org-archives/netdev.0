From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: dccp: add missing bind_conflict to
 dccp_ipv6_mapped
Date: Thu, 03 Nov 2016 08:59:46 -0700
Message-ID: <1478188786.7065.453.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+y8AEQ7dM6GQa5fezgaQK+arqAfRjyVafq-K0+nqgUvGg@mail.gmail.com>
         <CANn89i+YLvnFZFQTQyUA_jxYtZ1RE1NCCb3F4gqdia+w8wuK8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Konovalov <andreyknvl@google.com>,
        netdev <netdev@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33926 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758261AbcKCP7s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 11:59:48 -0400
In-Reply-To: <CANn89i+YLvnFZFQTQyUA_jxYtZ1RE1NCCb3F4gqdia+w8wuK8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While fuzzing kernel with syzkaller, Andrey reported a nasty crash
in inet6_bind() caused by DCCP lacking a required method.

Fixes: ab1e0a13d7029 ("[SOCK] proto: Add hashinfo member to struct proto")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Tested-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ipv6.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 3828f94b234c..95353bdbfa7b 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -956,6 +956,7 @@ static const struct inet_connection_sock_af_ops
dccp_ipv6_mapped = {
 	.getsockopt	   = ipv6_getsockopt,
 	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
 	.sockaddr_len	   = sizeof(struct sockaddr_in6),
+	.bind_conflict	   = inet6_csk_bind_conflict,
 #ifdef CONFIG_COMPAT
 	.compat_setsockopt = compat_ipv6_setsockopt,
 	.compat_getsockopt = compat_ipv6_getsockopt,
