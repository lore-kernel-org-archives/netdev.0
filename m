From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 2/3] security: keys: Replace time_t with time64_t for struct key_preparsed_payload
Date: Wed,  9 Aug 2017 10:51:31 +0800
Message-ID: <edd8fbb1ecfa2f5e45b5c09efbf67a59014d3cd9.1502246502.git.baolin.wang@linaro.org>
References: <cover.1502246501.git.baolin.wang@linaro.org>
Cc: james.l.morris@oracle.com, serge@hallyn.com,
        marc.dionne@auristor.com, dan.carpenter@oracle.com,
        Jason@zx2c4.com, arnd@arndb.de, broonie@kernel.org,
        keyrings@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        baolin.wang@linaro.org
To: dhowells@redhat.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502246501.git.baolin.wang@linaro.org>
In-Reply-To: <cover.1502246501.git.baolin.wang@linaro.org>
References: <cover.1502246501.git.baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 'struct key_preparsed_payload' will use 'time_t' which we will
try to remove in the kernel, since 'time_t' is not year 2038 safe on
32bits systems.

Thus this patch replaces 'time_t' with 'time64_t' which is year 2038
safe on 32 bits system for 'struct key_preparsed_payload', moreover
we should use the 'TIME64_MAX' macro to initialize the 'time64_t'
type variable.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 include/linux/key-type.h |    2 +-
 security/keys/key.c      |    8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/key-type.h b/include/linux/key-type.h
index 8496cf6..4beb006 100644
--- a/include/linux/key-type.h
+++ b/include/linux/key-type.h
@@ -44,7 +44,7 @@ struct key_preparsed_payload {
 	const void	*data;		/* Raw data */
 	size_t		datalen;	/* Raw datalen */
 	size_t		quotalen;	/* Quota length for proposed payload */
-	time_t		expiry;		/* Expiry time of key */
+	time64_t	expiry;		/* Expiry time of key */
 };
 
 typedef int (*request_key_actor_t)(struct key_construction *key,
diff --git a/security/keys/key.c b/security/keys/key.c
index 291a67c..d5c8941 100644
--- a/security/keys/key.c
+++ b/security/keys/key.c
@@ -446,7 +446,7 @@ static int __key_instantiate_and_link(struct key *key,
 			if (authkey)
 				key_revoke(authkey);
 
-			if (prep->expiry != TIME_T_MAX) {
+			if (prep->expiry != TIME64_MAX) {
 				key->expiry = prep->expiry;
 				key_schedule_gc(prep->expiry + key_gc_delay);
 			}
@@ -492,7 +492,7 @@ int key_instantiate_and_link(struct key *key,
 	prep.data = data;
 	prep.datalen = datalen;
 	prep.quotalen = key->type->def_datalen;
-	prep.expiry = TIME_T_MAX;
+	prep.expiry = TIME64_MAX;
 	if (key->type->preparse) {
 		ret = key->type->preparse(&prep);
 		if (ret < 0)
@@ -834,7 +834,7 @@ key_ref_t key_create_or_update(key_ref_t keyring_ref,
 	prep.data = payload;
 	prep.datalen = plen;
 	prep.quotalen = index_key.type->def_datalen;
-	prep.expiry = TIME_T_MAX;
+	prep.expiry = TIME64_MAX;
 	if (index_key.type->preparse) {
 		ret = index_key.type->preparse(&prep);
 		if (ret < 0) {
@@ -968,7 +968,7 @@ int key_update(key_ref_t key_ref, const void *payload, size_t plen)
 	prep.data = payload;
 	prep.datalen = plen;
 	prep.quotalen = key->type->def_datalen;
-	prep.expiry = TIME_T_MAX;
+	prep.expiry = TIME64_MAX;
 	if (key->type->preparse) {
 		ret = key->type->preparse(&prep);
 		if (ret < 0)
-- 
1.7.9.5
