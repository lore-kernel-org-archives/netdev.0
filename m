From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch net-next 2/2] [PATCH] net: ip, raw_diag -- Use jump for exiting from nested loop
Date: Wed, 02 Nov 2016 15:36:32 +0300
Message-ID: <20161102125454.754267793@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Cyrill Gorcunov <gorcunov@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33571 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753376AbcKBM4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 08:56:07 -0400
Received: by mail-lf0-f45.google.com with SMTP id c13so11675890lfg.0
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 05:56:06 -0700 (PDT)
Content-Disposition: inline; filename=inet-diag-raw-break-loop
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I managed to miss that sk_for_each is called under "for"
cycle so need to use goto here to return matching socket.

CC: David S. Miller <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Ahern <dsa@cumulusnetworks.com>
CC: Andrey Vagin <avagin@openvz.org>
CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 net/ipv4/raw_diag.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-ml.git/net/ipv4/raw_diag.c
===================================================================
--- linux-ml.git.orig/net/ipv4/raw_diag.c
+++ linux-ml.git/net/ipv4/raw_diag.c
@@ -79,10 +79,11 @@ static struct sock *raw_sock_get(struct
 				 * hashinfo->lock here.
 				 */
 				sock_hold(sk);
-				break;
+				goto out_unlock;
 			}
 		}
 	}
+out_unlock:
 	read_unlock(&hashinfo->lock);
 
 	return sk ? sk : ERR_PTR(-ENOENT);
