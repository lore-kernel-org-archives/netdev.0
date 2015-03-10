From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: better 32bit support
Date: Tue, 10 Mar 2015 09:56:47 -0700
Message-ID: <1426006607.11398.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:35560 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbbCJQ4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 12:56:50 -0400
Received: by iecsf10 with SMTP id sf10so21363083iec.2
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 09:56:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Socket cookies are 64bit, even if ss happens to be
a 32bit binary, running on a 64 bit host.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/ss.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 21a4366..ba58894 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -679,9 +679,9 @@ static inline char *sock_addr_get_str(const inet_prefix *prefix)
     return tmp;
 }
 
-static unsigned long cookie_sk_get(uint32_t *cookie)
+static unsigned long long cookie_sk_get(const uint32_t *cookie)
 {
-	return (((unsigned long)cookie[1] << 31) << 1) | cookie[0];
+	return (((unsigned long long)cookie[1] << 31) << 1) | cookie[0];
 }
 
 static const char *sstate_name[] = {
