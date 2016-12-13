From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH net-next] netlink: revert broken, broken "2-clause nla_ok()"
Date: Tue, 13 Dec 2016 22:30:15 +0300
Message-ID: <20161213193015.GA10610@avx2>
References: <CACVxJT9Qc=vNexx4ooQVFo=SrGs4-oHeZrnL18vbiS+o0F_N1A@mail.gmail.com>
 <1480950553.31788.40.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35437 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbcLMRaW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 12:30:22 -0500
Received: by mail-lf0-f66.google.com with SMTP id p100so4250107lfg.2
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 09:30:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480950553.31788.40.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 4f7df337fe79bba1e4c2d525525d63b5ba186bbd
"netlink: 2-clause nla_ok()" is BROKEN.

First clause tests if "->nla_len" could even be accessed at all,
it can not possibly be omitted.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netlink.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -698,7 +698,8 @@ static inline int nla_len(const struct nlattr *nla)
  */
 static inline int nla_ok(const struct nlattr *nla, int remaining)
 {
-	return nla->nla_len >= sizeof(*nla) &&
+	return remaining >= (int) sizeof(*nla) &&
+	       nla->nla_len >= sizeof(*nla) &&
 	       nla->nla_len <= remaining;
 }
 
