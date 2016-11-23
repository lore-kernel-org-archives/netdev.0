From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 02/11] ipv4: fib: Add fib_info_hold() helper
Date: Wed, 23 Nov 2016 15:34:23 +0100
Message-ID: <1479911670-4525-3-git-send-email-jiri@resnulli.us>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35135 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964967AbcKWOef (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:34:35 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so2193718wme.2
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 06:34:35 -0800 (PST)
In-Reply-To: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

As explained in the previous commit, modules are going to need to take a
reference on fib info and then drop it using fib_info_put().

Add the fib_info_hold() helper to make the code more readable and also
symmetric with fib_info_put().

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Suggested-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip_fib.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index f390c3b..6c67b93 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -397,6 +397,11 @@ static inline void fib_combine_itag(u32 *itag, const struct fib_result *res)
 
 void free_fib_info(struct fib_info *fi);
 
+static inline void fib_info_hold(struct fib_info *fi)
+{
+	atomic_inc(&fi->fib_clntref);
+}
+
 static inline void fib_info_put(struct fib_info *fi)
 {
 	if (atomic_dec_and_test(&fi->fib_clntref))
-- 
2.7.4
