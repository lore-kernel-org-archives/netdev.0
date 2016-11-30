From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 01/12] ipv4: fib: Export free_fib_info()
Date: Wed, 30 Nov 2016 11:08:55 +0100
Message-ID: <1480500546-2544-2-git-send-email-jiri@resnulli.us>
References: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33482 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754355AbcK3KJK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 05:09:10 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so28523153wmu.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 02:09:10 -0800 (PST)
In-Reply-To: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The FIB notification chain is going to be converted to an atomic chain,
which means switchdev drivers will have to offload FIB entries in
deferred work, as hardware operations entail sleeping.

However, while the work is queued fib info might be freed, so a
reference must be taken. To release the reference (and potentially free
the fib info) fib_info_put() will be called, which in turn calls
free_fib_info().

Export free_fib_info() so that modules will be able to invoke
fib_info_put().

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/ipv4/fib_semantics.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 388d3e2..c1bc1e9 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -234,6 +234,7 @@ void free_fib_info(struct fib_info *fi)
 #endif
 	call_rcu(&fi->rcu, free_fib_info_rcu);
 }
+EXPORT_SYMBOL_GPL(free_fib_info);
 
 void fib_release_info(struct fib_info *fi)
 {
-- 
2.7.4
