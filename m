From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/7] [CRYPTO] api: Split out low-level API
Date: Fri, 4 Aug 2006 23:34:26 +1000
Message-ID: <20060804133426.GB12832@gondor.apana.org.au>
References: <20060804133157.GA12787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40453 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161200AbWHDNea
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 09:34:30 -0400
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20060804133157.GA12787@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[CRYPTO] api: Split out low-level API

The crypto API is made up of the part facing users such as IPsec and the
low-level part which is used by cryptographic entities such as algorithms.
This patch splits out the latter so that the two APIs are more clearly
delineated.  As a bonus the low-level API can now be modularised if all
algorithms are built as modules.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/crypto/Kconfig b/crypto/Kconfig
--- a/crypto/Kconfig
+++ b/crypto/Kconfig
@@ -2,16 +2,21 @@
 # Cryptographic API Configuration
 #
 
-menu "Cryptographic options"
-
 config CRYPTO
 	bool "Cryptographic API"
 	help
 	  This option provides the core Cryptographic API.
 
+if CRYPTO
+
+menu "Cryptographic options"
+
+config CRYPTO_LOWAPI
+	tristate
+
 config CRYPTO_MANAGER
 	tristate "Cryptographic algorithm manager"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	default m
 	help
 	  Create default cryptographic template instantiations such as
@@ -19,45 +24,46 @@ config CRYPTO_MANAGER
 
 config CRYPTO_HMAC
 	tristate "HMAC support"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  HMAC: Keyed-Hashing for Message Authentication (RFC2104).
 	  This is required for IPSec.
 
 config CRYPTO_NULL
 	tristate "Null algorithms"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  These are 'Null' algorithms, used by IPsec, which do nothing.
 
 config CRYPTO_MD4
 	tristate "MD4 digest algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  MD4 message digest algorithm (RFC1320).
 
 config CRYPTO_MD5
 	tristate "MD5 digest algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  MD5 message digest algorithm (RFC1321).
 
 config CRYPTO_SHA1
 	tristate "SHA1 digest algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  SHA-1 secure hash standard (FIPS 180-1/DFIPS 180-2).
 
 config CRYPTO_SHA1_S390
 	tristate "SHA1 digest algorithm (s390)"
-	depends on CRYPTO && S390
+	depends on S390
+	select CRYPTO_LOWAPI
 	help
 	  This is the s390 hardware accelerated implementation of the
 	  SHA-1 secure hash standard (FIPS 180-1/DFIPS 180-2).
 
 config CRYPTO_SHA256
 	tristate "SHA256 digest algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  SHA256 secure hash standard (DFIPS 180-2).
 	  
@@ -66,7 +72,8 @@ config CRYPTO_SHA256
 
 config CRYPTO_SHA256_S390
 	tristate "SHA256 digest algorithm (s390)"
-	depends on CRYPTO && S390
+	depends on S390
+	select CRYPTO_LOWAPI
 	help
 	  This is the s390 hardware accelerated implementation of the
 	  SHA256 secure hash standard (DFIPS 180-2).
@@ -76,7 +83,7 @@ config CRYPTO_SHA256_S390
 
 config CRYPTO_SHA512
 	tristate "SHA384 and SHA512 digest algorithms"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  SHA512 secure hash standard (DFIPS 180-2).
 	  
@@ -88,7 +95,7 @@ config CRYPTO_SHA512
 
 config CRYPTO_WP512
 	tristate "Whirlpool digest algorithms"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  Whirlpool hash algorithm 512, 384 and 256-bit hashes
 
@@ -100,7 +107,7 @@ config CRYPTO_WP512
 
 config CRYPTO_TGR192
 	tristate "Tiger digest algorithms"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  Tiger hash algorithm 192, 160 and 128-bit hashes
 
@@ -113,19 +120,20 @@ config CRYPTO_TGR192
 
 config CRYPTO_DES
 	tristate "DES and Triple DES EDE cipher algorithms"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  DES cipher algorithm (FIPS 46-2), and Triple DES EDE (FIPS 46-3).
 
 config CRYPTO_DES_S390
 	tristate "DES and Triple DES cipher algorithms (s390)"
-	depends on CRYPTO && S390
+	depends on S390
+	select CRYPTO_LOWAPI
 	help
 	  DES cipher algorithm (FIPS 46-2), and Triple DES EDE (FIPS 46-3).
 
 config CRYPTO_BLOWFISH
 	tristate "Blowfish cipher algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  Blowfish cipher algorithm, by Bruce Schneier.
 	  
@@ -138,7 +146,7 @@ config CRYPTO_BLOWFISH
 
 config CRYPTO_TWOFISH
 	tristate "Twofish cipher algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	select CRYPTO_TWOFISH_COMMON
 	help
 	  Twofish cipher algorithm.
@@ -153,14 +161,14 @@ config CRYPTO_TWOFISH
 
 config CRYPTO_TWOFISH_COMMON
 	tristate
-	depends on CRYPTO
 	help
 	  Common parts of the Twofish cipher algorithm shared by the
 	  generic c and the assembler implementations.
 
 config CRYPTO_TWOFISH_586
 	tristate "Twofish cipher algorithms (i586)"
-	depends on CRYPTO && ((X86 || UML_X86) && !64BIT)
+	depends on (X86 || UML_X86) && !64BIT
+	select CRYPTO_LOWAPI
 	select CRYPTO_TWOFISH_COMMON
 	help
 	  Twofish cipher algorithm.
@@ -175,7 +183,8 @@ config CRYPTO_TWOFISH_586
 
 config CRYPTO_TWOFISH_X86_64
 	tristate "Twofish cipher algorithm (x86_64)"
-	depends on CRYPTO && ((X86 || UML_X86) && 64BIT)
+	depends on (X86 || UML_X86) && 64BIT
+	select CRYPTO_LOWAPI
 	select CRYPTO_TWOFISH_COMMON
 	help
 	  Twofish cipher algorithm (x86_64).
@@ -190,7 +199,7 @@ config CRYPTO_TWOFISH_X86_64
 
 config CRYPTO_SERPENT
 	tristate "Serpent cipher algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  Serpent cipher algorithm, by Anderson, Biham & Knudsen.
 
@@ -203,7 +212,7 @@ config CRYPTO_SERPENT
 
 config CRYPTO_AES
 	tristate "AES cipher algorithms"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  AES cipher algorithms (FIPS-197). AES uses the Rijndael 
 	  algorithm.
@@ -223,7 +232,8 @@ config CRYPTO_AES
 
 config CRYPTO_AES_586
 	tristate "AES cipher algorithms (i586)"
-	depends on CRYPTO && ((X86 || UML_X86) && !64BIT)
+	depends on (X86 || UML_X86) && !64BIT
+	select CRYPTO_LOWAPI
 	help
 	  AES cipher algorithms (FIPS-197). AES uses the Rijndael 
 	  algorithm.
@@ -243,7 +253,8 @@ config CRYPTO_AES_586
 
 config CRYPTO_AES_X86_64
 	tristate "AES cipher algorithms (x86_64)"
-	depends on CRYPTO && ((X86 || UML_X86) && 64BIT)
+	depends on (X86 || UML_X86) && 64BIT
+	select CRYPTO_LOWAPI
 	help
 	  AES cipher algorithms (FIPS-197). AES uses the Rijndael 
 	  algorithm.
@@ -263,7 +274,8 @@ config CRYPTO_AES_X86_64
 
 config CRYPTO_AES_S390
 	tristate "AES cipher algorithms (s390)"
-	depends on CRYPTO && S390
+	depends on S390
+	select CRYPTO_LOWAPI
 	help
 	  This is the s390 hardware accelerated implementation of the
 	  AES cipher algorithms (FIPS-197). AES uses the Rijndael
@@ -283,21 +295,21 @@ config CRYPTO_AES_S390
 
 config CRYPTO_CAST5
 	tristate "CAST5 (CAST-128) cipher algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  The CAST5 encryption algorithm (synonymous with CAST-128) is
 	  described in RFC2144.
 
 config CRYPTO_CAST6
 	tristate "CAST6 (CAST-256) cipher algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  The CAST6 encryption algorithm (synonymous with CAST-256) is
 	  described in RFC2612.
 
 config CRYPTO_TEA
 	tristate "TEA, XTEA and XETA cipher algorithms"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  TEA cipher algorithm.
 
@@ -314,7 +326,7 @@ config CRYPTO_TEA
 
 config CRYPTO_ARC4
 	tristate "ARC4 cipher algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  ARC4 cipher algorithm.
 
@@ -325,7 +337,7 @@ config CRYPTO_ARC4
 
 config CRYPTO_KHAZAD
 	tristate "Khazad cipher algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  Khazad cipher algorithm.
 
@@ -338,7 +350,7 @@ config CRYPTO_KHAZAD
 
 config CRYPTO_ANUBIS
 	tristate "Anubis cipher algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  Anubis cipher algorithm.
 
@@ -353,7 +365,7 @@ config CRYPTO_ANUBIS
 
 config CRYPTO_DEFLATE
 	tristate "Deflate compression algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	select ZLIB_INFLATE
 	select ZLIB_DEFLATE
 	help
@@ -364,7 +376,7 @@ config CRYPTO_DEFLATE
 
 config CRYPTO_MICHAEL_MIC
 	tristate "Michael MIC keyed digest algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	help
 	  Michael MIC is used for message integrity protection in TKIP
 	  (IEEE 802.11i). This algorithm is required for TKIP, but it
@@ -373,7 +385,7 @@ config CRYPTO_MICHAEL_MIC
 
 config CRYPTO_CRC32C
 	tristate "CRC32c CRC algorithm"
-	depends on CRYPTO
+	select CRYPTO_LOWAPI
 	select LIBCRC32C
 	help
 	  Castagnoli, et al Cyclic Redundancy-Check Algorithm.  Used
@@ -383,10 +395,13 @@ config CRYPTO_CRC32C
 
 config CRYPTO_TEST
 	tristate "Testing module"
-	depends on CRYPTO && m
+	depends on m
+	select CRYPTO_LOWAPI
 	help
 	  Quick & dirty crypto test module.
 
 source "drivers/crypto/Kconfig"
+
 endmenu
 
+endif	# if CRYPTO
diff --git a/crypto/Makefile b/crypto/Makefile
--- a/crypto/Makefile
+++ b/crypto/Makefile
@@ -2,10 +2,11 @@
 # Cryptographic API
 #
 
-proc-crypto-$(CONFIG_PROC_FS) = proc.o
+obj-$(CONFIG_CRYPTO) += api.o scatterwalk.o cipher.o digest.o compress.o
 
-obj-$(CONFIG_CRYPTO) += api.o scatterwalk.o cipher.o digest.o compress.o \
-			$(proc-crypto-y)
+crypto_lowapi-$(CONFIG_PROC_FS) += proc.o
+crypto_lowapi-objs := lowapi.o $(crypto_lowapi-y)
+obj-$(CONFIG_CRYPTO_LOWAPI) += crypto_lowapi.o
 
 obj-$(CONFIG_CRYPTO_MANAGER) += cryptomgr.o
 obj-$(CONFIG_CRYPTO_HMAC) += hmac.o
diff --git a/crypto/api.c b/crypto/api.c
--- a/crypto/api.c
+++ b/crypto/api.c
@@ -15,30 +15,23 @@
  *
  */
 
-#include <linux/compiler.h>
-#include <linux/init.h>
-#include <linux/crypto.h>
 #include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
-#include <linux/kmod.h>
 #include <linux/module.h>
-#include <linux/notifier.h>
 #include <linux/param.h>
-#include <linux/rwsem.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include "internal.h"
 
 LIST_HEAD(crypto_alg_list);
-static LIST_HEAD(crypto_template_list);
+EXPORT_SYMBOL_GPL(crypto_alg_list);
 DECLARE_RWSEM(crypto_alg_sem);
+EXPORT_SYMBOL_GPL(crypto_alg_sem);
 
-static BLOCKING_NOTIFIER_HEAD(crypto_chain);
-
-static void crypto_destroy_instance(struct crypto_alg *alg);
-static void crypto_remove_final(struct list_head *list);
+BLOCKING_NOTIFIER_HEAD(crypto_chain);
+EXPORT_SYMBOL_GPL(crypto_chain);
 
 static inline struct crypto_alg *crypto_alg_get(struct crypto_alg *alg)
 {
@@ -46,16 +39,11 @@ static inline struct crypto_alg *crypto_
 	return alg;
 }
 
-static inline void crypto_alg_put(struct crypto_alg *alg)
-{
-	if (atomic_dec_and_test(&alg->cra_refcnt) && alg->cra_destroy)
-		alg->cra_destroy(alg);
-}
-
-static struct crypto_alg *crypto_mod_get(struct crypto_alg *alg)
+struct crypto_alg *crypto_mod_get(struct crypto_alg *alg)
 {
 	return try_module_get(alg->cra_module) ? crypto_alg_get(alg) : NULL;
 }
+EXPORT_SYMBOL_GPL(crypto_mod_get);
 
 void crypto_mod_put(struct crypto_alg *alg)
 {
@@ -64,28 +52,7 @@ void crypto_mod_put(struct crypto_alg *a
 }
 EXPORT_SYMBOL_GPL(crypto_mod_put);
 
-static inline int crypto_is_larval(struct crypto_alg *alg)
-{
-	return alg->cra_flags & CRYPTO_ALG_LARVAL;
-}
-
-static inline int crypto_is_dead(struct crypto_alg *alg)
-{
-	return alg->cra_flags & CRYPTO_ALG_DEAD;
-}
-
-static inline int crypto_is_moribund(struct crypto_alg *alg)
-{
-	return alg->cra_flags & (CRYPTO_ALG_DEAD | CRYPTO_ALG_DYING);
-}
-
-static inline int crypto_notify(unsigned long val, void *v)
-{
-	return blocking_notifier_call_chain(&crypto_chain, val, v);
-}
-
-static struct crypto_alg *__crypto_alg_lookup(const char *name, u32 type,
-					      u32 mask)
+struct crypto_alg *__crypto_alg_lookup(const char *name, u32 type, u32 mask)
 {
 	struct crypto_alg *q, *alg = NULL;
 	int best = -2;
@@ -122,6 +89,7 @@ static struct crypto_alg *__crypto_alg_l
 
 	return alg;
 }
+EXPORT_SYMBOL_GPL(__crypto_alg_lookup);
 
 static void crypto_larval_destroy(struct crypto_alg *alg)
 {
@@ -193,24 +161,6 @@ static struct crypto_alg *crypto_larval_
 	return alg;
 }
 
-void crypto_larval_error(const char *name, u32 type, u32 mask)
-{
-	struct crypto_alg *alg;
-
-	down_read(&crypto_alg_sem);
-	alg = __crypto_alg_lookup(name, type, mask);
-	up_read(&crypto_alg_sem);
-
-	if (alg) {
-		if (crypto_is_larval(alg)) {
-			struct crypto_larval *larval = (void *)alg;
-			complete(&larval->completion);
-		}
-		crypto_mod_put(alg);
-	}
-}
-EXPORT_SYMBOL_GPL(crypto_larval_error);
-
 static struct crypto_alg *crypto_alg_lookup(const char *name, u32 type,
 					    u32 mask)
 {
@@ -349,14 +299,15 @@ static unsigned int crypto_ctxsize(struc
 	return len + (alg->cra_alignmask & ~(crypto_tfm_ctx_alignment() - 1));
 }
 
-static void crypto_shoot_alg(struct crypto_alg *alg)
+void crypto_shoot_alg(struct crypto_alg *alg)
 {
 	down_write(&crypto_alg_sem);
 	alg->cra_flags |= CRYPTO_ALG_DYING;
 	up_write(&crypto_alg_sem);
 }
+EXPORT_SYMBOL_GPL(crypto_shoot_alg);
 
-static struct crypto_tfm *__crypto_alloc_tfm(struct crypto_alg *alg, u32 flags)
+struct crypto_tfm *__crypto_alloc_tfm(struct crypto_alg *alg, u32 flags)
 {
 	struct crypto_tfm *tfm = NULL;
 	unsigned int tfm_size;
@@ -393,6 +344,7 @@ out_free_tfm:
 out:
 	return tfm;
 }
+EXPORT_SYMBOL_GPL(__crypto_alloc_tfm);
 
 struct crypto_tfm *crypto_alloc_tfm(const char *name, u32 flags)
 {
@@ -438,366 +390,6 @@ void crypto_free_tfm(struct crypto_tfm *
 	kfree(tfm);
 }
 
-static inline int crypto_set_driver_name(struct crypto_alg *alg)
-{
-	static const char suffix[] = "-generic";
-	char *driver_name = alg->cra_driver_name;
-	int len;
-
-	if (*driver_name)
-		return 0;
-
-	len = strlcpy(driver_name, alg->cra_name, CRYPTO_MAX_ALG_NAME);
-	if (len + sizeof(suffix) > CRYPTO_MAX_ALG_NAME)
-		return -ENAMETOOLONG;
-
-	memcpy(driver_name + len, suffix, sizeof(suffix));
-	return 0;
-}
-
-static int crypto_check_alg(struct crypto_alg *alg)
-{
-	if (alg->cra_alignmask & (alg->cra_alignmask + 1))
-		return -EINVAL;
-
-	if (alg->cra_alignmask & alg->cra_blocksize)
-		return -EINVAL;
-
-	if (alg->cra_blocksize > PAGE_SIZE / 8)
-		return -EINVAL;
-
-	if (alg->cra_priority < 0)
-		return -EINVAL;
-	
-	return crypto_set_driver_name(alg);
-}
-
-static void crypto_remove_spawns(struct list_head *spawns,
-				 struct list_head *list)
-{
-	struct crypto_spawn *spawn, *n;
-
-	list_for_each_entry_safe(spawn, n, spawns, list) {
-		struct crypto_instance *inst = spawn->inst;
-		struct crypto_template *tmpl = inst->tmpl;
-
-		list_del_init(&spawn->list);
-		spawn->alg = NULL;
-
-		if (crypto_is_dead(&inst->alg))
-			continue;
-
-		inst->alg.cra_flags |= CRYPTO_ALG_DEAD;
-		if (!tmpl || !crypto_tmpl_get(tmpl))
-			continue;
-
-		crypto_notify(CRYPTO_MSG_ALG_UNREGISTER, &inst->alg);
-		list_move(&inst->alg.cra_list, list);
-		hlist_del(&inst->list);
-		inst->alg.cra_destroy = crypto_destroy_instance;
-
-		if (!list_empty(&inst->alg.cra_users)) {
-			if (&n->list == spawns)
-				n = list_entry(inst->alg.cra_users.next,
-					       typeof(*n), list);
-			__list_splice(&inst->alg.cra_users, spawns->prev);
-		}
-	}
-}
-
-static int __crypto_register_alg(struct crypto_alg *alg,
-				 struct list_head *list)
-{
-	struct crypto_alg *q;
-	int ret = -EAGAIN;
-
-	if (crypto_is_dead(alg))
-		goto out;
-
-	INIT_LIST_HEAD(&alg->cra_users);
-
-	ret = -EEXIST;
-	atomic_set(&alg->cra_refcnt, 1);
-	list_for_each_entry(q, &crypto_alg_list, cra_list) {
-		if (q == alg)
-			goto out;
-
-		if (crypto_is_moribund(q))
-			continue;
-
-		if (crypto_is_larval(q)) {
-			struct crypto_larval *larval = (void *)q;
-
-			if (strcmp(alg->cra_name, q->cra_name) &&
-			    strcmp(alg->cra_driver_name, q->cra_name))
-				continue;
-
-			if (larval->adult)
-				continue;
-			if ((q->cra_flags ^ alg->cra_flags) & larval->mask)
-				continue;
-			if (!crypto_mod_get(alg))
-				continue;
-
-			larval->adult = alg;
-			complete(&larval->completion);
-			continue;
-		}
-
-		if (strcmp(alg->cra_name, q->cra_name))
-			continue;
-
-		if (strcmp(alg->cra_driver_name, q->cra_driver_name) &&
-		    q->cra_priority > alg->cra_priority)
-			continue;
-
-		crypto_remove_spawns(&q->cra_users, list);
-	}
-	
-	list_add(&alg->cra_list, &crypto_alg_list);
-
-	crypto_notify(CRYPTO_MSG_ALG_REGISTER, alg);
-	ret = 0;
-
-out:	
-	return ret;
-}
-
-int crypto_register_alg(struct crypto_alg *alg)
-{
-	LIST_HEAD(list);
-	int err;
-
-	err = crypto_check_alg(alg);
-	if (err)
-		return err;
-
-	down_write(&crypto_alg_sem);
-	err = __crypto_register_alg(alg, &list);
-	up_write(&crypto_alg_sem);
-
-	crypto_remove_final(&list);
-	return err;
-}
-
-static void crypto_destroy_instance(struct crypto_alg *alg)
-{
-	struct crypto_instance *inst = (void *)alg;
-	struct crypto_template *tmpl = inst->tmpl;
-
-	tmpl->free(inst);
-	crypto_tmpl_put(tmpl);
-}
-
-static int crypto_remove_alg(struct crypto_alg *alg, struct list_head *list)
-{
-	if (unlikely(list_empty(&alg->cra_list)))
-		return -ENOENT;
-
-	alg->cra_flags |= CRYPTO_ALG_DEAD;
-
-	crypto_notify(CRYPTO_MSG_ALG_UNREGISTER, alg);
-	list_del_init(&alg->cra_list);
-	crypto_remove_spawns(&alg->cra_users, list);
-
-	return 0;
-}
-
-static void crypto_remove_final(struct list_head *list)
-{
-	struct crypto_alg *alg;
-	struct crypto_alg *n;
-
-	list_for_each_entry_safe(alg, n, list, cra_list) {
-		list_del_init(&alg->cra_list);
-		crypto_alg_put(alg);
-	}
-}
-
-int crypto_unregister_alg(struct crypto_alg *alg)
-{
-	int ret;
-	LIST_HEAD(list);
-	
-	down_write(&crypto_alg_sem);
-	ret = crypto_remove_alg(alg, &list);
-	up_write(&crypto_alg_sem);
-
-	if (ret)
-		return ret;
-
-	BUG_ON(atomic_read(&alg->cra_refcnt) != 1);
-	if (alg->cra_destroy)
-		alg->cra_destroy(alg);
-
-	crypto_remove_final(&list);
-	return 0;
-}
-
-int crypto_register_template(struct crypto_template *tmpl)
-{
-	struct crypto_template *q;
-	int err = -EEXIST;
-
-	down_write(&crypto_alg_sem);
-
-	list_for_each_entry(q, &crypto_template_list, list) {
-		if (q == tmpl)
-			goto out;
-	}
-
-	list_add(&tmpl->list, &crypto_template_list);
-	crypto_notify(CRYPTO_MSG_TMPL_REGISTER, tmpl);
-	err = 0;
-out:
-	up_write(&crypto_alg_sem);
-	return err;
-}
-EXPORT_SYMBOL_GPL(crypto_register_template);
-
-void crypto_unregister_template(struct crypto_template *tmpl)
-{
-	struct crypto_instance *inst;
-	struct hlist_node *p, *n;
-	struct hlist_head *list;
-	LIST_HEAD(users);
-
-	down_write(&crypto_alg_sem);
-
-	BUG_ON(list_empty(&tmpl->list));
-	list_del_init(&tmpl->list);
-
-	list = &tmpl->instances;
-	hlist_for_each_entry(inst, p, list, list) {
-		int err = crypto_remove_alg(&inst->alg, &users);
-		BUG_ON(err);
-	}
-
-	crypto_notify(CRYPTO_MSG_TMPL_UNREGISTER, tmpl);
-
-	up_write(&crypto_alg_sem);
-
-	hlist_for_each_entry_safe(inst, p, n, list, list) {
-		BUG_ON(atomic_read(&inst->alg.cra_refcnt) != 1);
-		tmpl->free(inst);
-	}
-	crypto_remove_final(&users);
-}
-EXPORT_SYMBOL_GPL(crypto_unregister_template);
-
-static struct crypto_template *__crypto_lookup_template(const char *name)
-{
-	struct crypto_template *q, *tmpl = NULL;
-
-	down_read(&crypto_alg_sem);
-	list_for_each_entry(q, &crypto_template_list, list) {
-		if (strcmp(q->name, name))
-			continue;
-		if (unlikely(!crypto_tmpl_get(q)))
-			continue;
-
-		tmpl = q;
-		break;
-	}
-	up_read(&crypto_alg_sem);
-
-	return tmpl;
-}
-
-struct crypto_template *crypto_lookup_template(const char *name)
-{
-	return try_then_request_module(__crypto_lookup_template(name), name);
-}
-EXPORT_SYMBOL_GPL(crypto_lookup_template);
-
-int crypto_register_instance(struct crypto_template *tmpl,
-			     struct crypto_instance *inst)
-{
-	LIST_HEAD(list);
-	int err = -EINVAL;
-
-	if (inst->alg.cra_destroy)
-		goto err;
-
-	err = crypto_check_alg(&inst->alg);
-	if (err)
-		goto err;
-
-	inst->alg.cra_module = tmpl->module;
-
-	down_write(&crypto_alg_sem);
-
-	err = __crypto_register_alg(&inst->alg, &list);
-	if (err)
-		goto unlock;
-
-	hlist_add_head(&inst->list, &tmpl->instances);
-	inst->tmpl = tmpl;
-
-unlock:
-	up_write(&crypto_alg_sem);
-
-	crypto_remove_final(&list);
-
-err:
-	return err;
-}
-EXPORT_SYMBOL_GPL(crypto_register_instance);
-
-int crypto_init_spawn(struct crypto_spawn *spawn, struct crypto_alg *alg,
-		      struct crypto_instance *inst)
-{
-	int err = -EAGAIN;
-
-	spawn->inst = inst;
-
-	down_write(&crypto_alg_sem);
-	if (!crypto_is_moribund(alg)) {
-		list_add(&spawn->list, &alg->cra_users);
-		spawn->alg = alg;
-		err = 0;
-	}
-	up_write(&crypto_alg_sem);
-
-	return err;
-}
-EXPORT_SYMBOL_GPL(crypto_init_spawn);
-
-void crypto_drop_spawn(struct crypto_spawn *spawn)
-{
-	down_write(&crypto_alg_sem);
-	list_del(&spawn->list);
-	up_write(&crypto_alg_sem);
-}
-EXPORT_SYMBOL_GPL(crypto_drop_spawn);
-
-struct crypto_tfm *crypto_spawn_tfm(struct crypto_spawn *spawn)
-{
-	struct crypto_alg *alg;
-	struct crypto_alg *alg2;
-	struct crypto_tfm *tfm;
-
-	down_read(&crypto_alg_sem);
-	alg = spawn->alg;
-	alg2 = alg;
-	if (alg2)
-		alg2 = crypto_mod_get(alg2);
-	up_read(&crypto_alg_sem);
-
-	if (!alg2) {
-		if (alg)
-			crypto_shoot_alg(alg);
-		return ERR_PTR(-EAGAIN);
-	}
-
-	tfm = __crypto_alloc_tfm(alg, 0);
-	if (IS_ERR(tfm))
-		crypto_mod_put(alg);
-
-	return tfm;
-}
-EXPORT_SYMBOL_GPL(crypto_spawn_tfm);
-
 int crypto_alg_available(const char *name, u32 flags)
 {
 	int ret = 0;
@@ -811,29 +403,6 @@ int crypto_alg_available(const char *nam
 	return ret;
 }
 
-int crypto_register_notifier(struct notifier_block *nb)
-{
-	return blocking_notifier_chain_register(&crypto_chain, nb);
-}
-EXPORT_SYMBOL_GPL(crypto_register_notifier);
-
-int crypto_unregister_notifier(struct notifier_block *nb)
-{
-	return blocking_notifier_chain_unregister(&crypto_chain, nb);
-}
-EXPORT_SYMBOL_GPL(crypto_unregister_notifier);
-
-static int __init init_crypto(void)
-{
-	printk(KERN_INFO "Initializing Cryptographic API\n");
-	crypto_init_proc();
-	return 0;
-}
-
-__initcall(init_crypto);
-
-EXPORT_SYMBOL_GPL(crypto_register_alg);
-EXPORT_SYMBOL_GPL(crypto_unregister_alg);
 EXPORT_SYMBOL_GPL(crypto_alloc_tfm);
 EXPORT_SYMBOL_GPL(crypto_free_tfm);
 EXPORT_SYMBOL_GPL(crypto_alg_available);
diff --git a/crypto/hmac.c b/crypto/hmac.c
--- a/crypto/hmac.c
+++ b/crypto/hmac.c
@@ -15,14 +15,13 @@
  * any later version.
  *
  */
-#include <linux/crypto.h>
+#include <crypto/lowapi.h>
 #include <linux/err.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/rtnetlink.h>
 #include <linux/slab.h>
 #include <linux/scatterlist.h>
-#include "internal.h"
 
 struct crypto_hmac_ctx {
 	struct crypto_tfm *child;
diff --git a/crypto/internal.h b/crypto/internal.h
--- a/crypto/internal.h
+++ b/crypto/internal.h
@@ -13,8 +13,8 @@
 #ifndef _CRYPTO_INTERNAL_H
 #define _CRYPTO_INTERNAL_H
 
+#include <crypto/lowapi.h>
 #include <linux/completion.h>
-#include <linux/crypto.h>
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/interrupt.h>
@@ -22,9 +22,9 @@
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/notifier.h>
 #include <linux/rwsem.h>
 #include <linux/slab.h>
-#include <linux/types.h>
 #include <asm/kmap_types.h>
 
 /* Crypto notification events. */
@@ -36,27 +36,8 @@ enum {
 	CRYPTO_MSG_TMPL_UNREGISTER,
 };
 
-struct notifier_block;
-
-struct crypto_instance {
-	struct crypto_alg alg;
-
-	struct crypto_template *tmpl;
-	struct hlist_node list;
-
-	char __ctx[] __attribute__ ((__aligned__));
-};
-
-struct crypto_template {
-	struct list_head list;
-	struct hlist_head instances;
-	struct module *module;
-
-	struct crypto_instance *(*alloc)(void *param, unsigned int len);
-	void (*free)(struct crypto_instance *inst);
-
-	char name[CRYPTO_MAX_ALG_NAME];
-};
+struct crypto_instance;
+struct crypto_template;
 
 struct crypto_larval {
 	struct crypto_alg alg;
@@ -65,14 +46,9 @@ struct crypto_larval {
 	u32 mask;
 };
 
-struct crypto_spawn {
-	struct list_head list;
-	struct crypto_alg *alg;
-	struct crypto_instance *inst;
-};
-
 extern struct list_head crypto_alg_list;
 extern struct rw_semaphore crypto_alg_sem;
+extern struct blocking_notifier_head crypto_chain;
 
 extern enum km_type crypto_km_types[];
 
@@ -99,9 +75,12 @@ static inline void crypto_yield(struct c
 
 #ifdef CONFIG_PROC_FS
 void __init crypto_init_proc(void);
+void __exit crypto_exit_proc(void);
 #else
 static inline void crypto_init_proc(void)
 { }
+static inline void crypto_exit_proc(void)
+{ }
 #endif
 
 static inline unsigned int crypto_digest_ctxsize(struct crypto_alg *alg,
@@ -138,6 +117,9 @@ static inline unsigned int crypto_compre
 	return alg->cra_ctxsize;
 }
 
+struct crypto_alg *crypto_mod_get(struct crypto_alg *alg);
+struct crypto_alg *__crypto_alg_lookup(const char *name, u32 type, u32 mask);
+
 int crypto_init_digest_flags(struct crypto_tfm *tfm, u32 flags);
 int crypto_init_cipher_flags(struct crypto_tfm *tfm, u32 flags);
 int crypto_init_compress_flags(struct crypto_tfm *tfm, u32 flags);
@@ -150,27 +132,21 @@ void crypto_exit_digest_ops(struct crypt
 void crypto_exit_cipher_ops(struct crypto_tfm *tfm);
 void crypto_exit_compress_ops(struct crypto_tfm *tfm);
 
-void crypto_mod_put(struct crypto_alg *alg);
 void crypto_larval_error(const char *name, u32 type, u32 mask);
-struct crypto_alg *crypto_alg_mod_lookup(const char *name, u32 type, u32 mask);
 
-int crypto_register_template(struct crypto_template *tmpl);
-void crypto_unregister_template(struct crypto_template *tmpl);
-struct crypto_template *crypto_lookup_template(const char *name);
+void crypto_shoot_alg(struct crypto_alg *alg);
+struct crypto_tfm *__crypto_alloc_tfm(struct crypto_alg *alg, u32 flags);
+
 int crypto_register_instance(struct crypto_template *tmpl,
 			     struct crypto_instance *inst);
 
 int crypto_register_notifier(struct notifier_block *nb);
 int crypto_unregister_notifier(struct notifier_block *nb);
 
-int crypto_init_spawn(struct crypto_spawn *spawn, struct crypto_alg *alg,
-		      struct crypto_instance *inst);
-void crypto_drop_spawn(struct crypto_spawn *spawn);
-struct crypto_tfm *crypto_spawn_tfm(struct crypto_spawn *spawn);
-
-static inline void *crypto_instance_ctx(struct crypto_instance *inst)
+static inline void crypto_alg_put(struct crypto_alg *alg)
 {
-	return inst->__ctx;
+	if (atomic_dec_and_test(&alg->cra_refcnt) && alg->cra_destroy)
+		alg->cra_destroy(alg);
 }
 
 static inline int crypto_tmpl_get(struct crypto_template *tmpl)
@@ -183,5 +159,25 @@ static inline void crypto_tmpl_put(struc
 	module_put(tmpl->module);
 }
 
+static inline int crypto_is_larval(struct crypto_alg *alg)
+{
+	return alg->cra_flags & CRYPTO_ALG_LARVAL;
+}
+
+static inline int crypto_is_dead(struct crypto_alg *alg)
+{
+	return alg->cra_flags & CRYPTO_ALG_DEAD;
+}
+
+static inline int crypto_is_moribund(struct crypto_alg *alg)
+{
+	return alg->cra_flags & (CRYPTO_ALG_DEAD | CRYPTO_ALG_DYING);
+}
+
+static inline int crypto_notify(unsigned long val, void *v)
+{
+	return blocking_notifier_call_chain(&crypto_chain, val, v);
+}
+
 #endif	/* _CRYPTO_INTERNAL_H */
 
diff --git a/crypto/lowapi.c b/crypto/lowapi.c
new file mode 100644
--- /dev/null
+++ b/crypto/lowapi.c
@@ -0,0 +1,433 @@
+/*
+ * Cryptographic API for algorithms (i.e., low-level API).
+ *
+ * Copyright (c) 2006 Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ */
+
+#include <linux/err.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/module.h>
+#include <linux/string.h>
+
+#include "internal.h"
+
+static LIST_HEAD(crypto_template_list);
+
+void crypto_larval_error(const char *name, u32 type, u32 mask)
+{
+	struct crypto_alg *alg;
+
+	down_read(&crypto_alg_sem);
+	alg = __crypto_alg_lookup(name, type, mask);
+	up_read(&crypto_alg_sem);
+
+	if (alg) {
+		if (crypto_is_larval(alg)) {
+			struct crypto_larval *larval = (void *)alg;
+			complete(&larval->completion);
+		}
+		crypto_mod_put(alg);
+	}
+}
+EXPORT_SYMBOL_GPL(crypto_larval_error);
+
+static inline int crypto_set_driver_name(struct crypto_alg *alg)
+{
+	static const char suffix[] = "-generic";
+	char *driver_name = alg->cra_driver_name;
+	int len;
+
+	if (*driver_name)
+		return 0;
+
+	len = strlcpy(driver_name, alg->cra_name, CRYPTO_MAX_ALG_NAME);
+	if (len + sizeof(suffix) > CRYPTO_MAX_ALG_NAME)
+		return -ENAMETOOLONG;
+
+	memcpy(driver_name + len, suffix, sizeof(suffix));
+	return 0;
+}
+
+static int crypto_check_alg(struct crypto_alg *alg)
+{
+	if (alg->cra_alignmask & (alg->cra_alignmask + 1))
+		return -EINVAL;
+
+	if (alg->cra_alignmask & alg->cra_blocksize)
+		return -EINVAL;
+
+	if (alg->cra_blocksize > PAGE_SIZE / 8)
+		return -EINVAL;
+
+	if (alg->cra_priority < 0)
+		return -EINVAL;
+	
+	return crypto_set_driver_name(alg);
+}
+
+static void crypto_destroy_instance(struct crypto_alg *alg)
+{
+	struct crypto_instance *inst = (void *)alg;
+	struct crypto_template *tmpl = inst->tmpl;
+
+	tmpl->free(inst);
+	crypto_tmpl_put(tmpl);
+}
+
+static void crypto_remove_spawns(struct list_head *spawns,
+				 struct list_head *list)
+{
+	struct crypto_spawn *spawn, *n;
+
+	list_for_each_entry_safe(spawn, n, spawns, list) {
+		struct crypto_instance *inst = spawn->inst;
+		struct crypto_template *tmpl = inst->tmpl;
+
+		list_del_init(&spawn->list);
+		spawn->alg = NULL;
+
+		if (crypto_is_dead(&inst->alg))
+			continue;
+
+		inst->alg.cra_flags |= CRYPTO_ALG_DEAD;
+		if (!tmpl || !crypto_tmpl_get(tmpl))
+			continue;
+
+		crypto_notify(CRYPTO_MSG_ALG_UNREGISTER, &inst->alg);
+		list_move(&inst->alg.cra_list, list);
+		hlist_del(&inst->list);
+		inst->alg.cra_destroy = crypto_destroy_instance;
+
+		if (!list_empty(&inst->alg.cra_users)) {
+			if (&n->list == spawns)
+				n = list_entry(inst->alg.cra_users.next,
+					       typeof(*n), list);
+			__list_splice(&inst->alg.cra_users, spawns->prev);
+		}
+	}
+}
+
+static int __crypto_register_alg(struct crypto_alg *alg,
+				 struct list_head *list)
+{
+	struct crypto_alg *q;
+	int ret = -EAGAIN;
+
+	if (crypto_is_dead(alg))
+		goto out;
+
+	INIT_LIST_HEAD(&alg->cra_users);
+
+	ret = -EEXIST;
+	atomic_set(&alg->cra_refcnt, 1);
+	list_for_each_entry(q, &crypto_alg_list, cra_list) {
+		if (q == alg)
+			goto out;
+
+		if (crypto_is_moribund(q))
+			continue;
+
+		if (crypto_is_larval(q)) {
+			struct crypto_larval *larval = (void *)q;
+
+			if (strcmp(alg->cra_name, q->cra_name) &&
+			    strcmp(alg->cra_driver_name, q->cra_name))
+				continue;
+
+			if (larval->adult)
+				continue;
+			if ((q->cra_flags ^ alg->cra_flags) & larval->mask)
+				continue;
+			if (!crypto_mod_get(alg))
+				continue;
+
+			larval->adult = alg;
+			complete(&larval->completion);
+			continue;
+		}
+
+		if (strcmp(alg->cra_name, q->cra_name))
+			continue;
+
+		if (strcmp(alg->cra_driver_name, q->cra_driver_name) &&
+		    q->cra_priority > alg->cra_priority)
+			continue;
+
+		crypto_remove_spawns(&q->cra_users, list);
+	}
+	
+	list_add(&alg->cra_list, &crypto_alg_list);
+
+	crypto_notify(CRYPTO_MSG_ALG_REGISTER, alg);
+	ret = 0;
+
+out:	
+	return ret;
+}
+
+static void crypto_remove_final(struct list_head *list)
+{
+	struct crypto_alg *alg;
+	struct crypto_alg *n;
+
+	list_for_each_entry_safe(alg, n, list, cra_list) {
+		list_del_init(&alg->cra_list);
+		crypto_alg_put(alg);
+	}
+}
+
+int crypto_register_alg(struct crypto_alg *alg)
+{
+	LIST_HEAD(list);
+	int err;
+
+	err = crypto_check_alg(alg);
+	if (err)
+		return err;
+
+	down_write(&crypto_alg_sem);
+	err = __crypto_register_alg(alg, &list);
+	up_write(&crypto_alg_sem);
+
+	crypto_remove_final(&list);
+	return err;
+}
+EXPORT_SYMBOL_GPL(crypto_register_alg);
+
+static int crypto_remove_alg(struct crypto_alg *alg, struct list_head *list)
+{
+	if (unlikely(list_empty(&alg->cra_list)))
+		return -ENOENT;
+
+	alg->cra_flags |= CRYPTO_ALG_DEAD;
+
+	crypto_notify(CRYPTO_MSG_ALG_UNREGISTER, alg);
+	list_del_init(&alg->cra_list);
+	crypto_remove_spawns(&alg->cra_users, list);
+
+	return 0;
+}
+
+int crypto_unregister_alg(struct crypto_alg *alg)
+{
+	int ret;
+	LIST_HEAD(list);
+	
+	down_write(&crypto_alg_sem);
+	ret = crypto_remove_alg(alg, &list);
+	up_write(&crypto_alg_sem);
+
+	if (ret)
+		return ret;
+
+	BUG_ON(atomic_read(&alg->cra_refcnt) != 1);
+	if (alg->cra_destroy)
+		alg->cra_destroy(alg);
+
+	crypto_remove_final(&list);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(crypto_unregister_alg);
+
+int crypto_register_template(struct crypto_template *tmpl)
+{
+	struct crypto_template *q;
+	int err = -EEXIST;
+
+	down_write(&crypto_alg_sem);
+
+	list_for_each_entry(q, &crypto_template_list, list) {
+		if (q == tmpl)
+			goto out;
+	}
+
+	list_add(&tmpl->list, &crypto_template_list);
+	crypto_notify(CRYPTO_MSG_TMPL_REGISTER, tmpl);
+	err = 0;
+out:
+	up_write(&crypto_alg_sem);
+	return err;
+}
+EXPORT_SYMBOL_GPL(crypto_register_template);
+
+void crypto_unregister_template(struct crypto_template *tmpl)
+{
+	struct crypto_instance *inst;
+	struct hlist_node *p, *n;
+	struct hlist_head *list;
+	LIST_HEAD(users);
+
+	down_write(&crypto_alg_sem);
+
+	BUG_ON(list_empty(&tmpl->list));
+	list_del_init(&tmpl->list);
+
+	list = &tmpl->instances;
+	hlist_for_each_entry(inst, p, list, list) {
+		int err = crypto_remove_alg(&inst->alg, &users);
+		BUG_ON(err);
+	}
+
+	crypto_notify(CRYPTO_MSG_TMPL_UNREGISTER, tmpl);
+
+	up_write(&crypto_alg_sem);
+
+	hlist_for_each_entry_safe(inst, p, n, list, list) {
+		BUG_ON(atomic_read(&inst->alg.cra_refcnt) != 1);
+		tmpl->free(inst);
+	}
+	crypto_remove_final(&users);
+}
+EXPORT_SYMBOL_GPL(crypto_unregister_template);
+
+static struct crypto_template *__crypto_lookup_template(const char *name)
+{
+	struct crypto_template *q, *tmpl = NULL;
+
+	down_read(&crypto_alg_sem);
+	list_for_each_entry(q, &crypto_template_list, list) {
+		if (strcmp(q->name, name))
+			continue;
+		if (unlikely(!crypto_tmpl_get(q)))
+			continue;
+
+		tmpl = q;
+		break;
+	}
+	up_read(&crypto_alg_sem);
+
+	return tmpl;
+}
+
+struct crypto_template *crypto_lookup_template(const char *name)
+{
+	return try_then_request_module(__crypto_lookup_template(name), name);
+}
+EXPORT_SYMBOL_GPL(crypto_lookup_template);
+
+int crypto_register_instance(struct crypto_template *tmpl,
+			     struct crypto_instance *inst)
+{
+	LIST_HEAD(list);
+	int err = -EINVAL;
+
+	if (inst->alg.cra_destroy)
+		goto err;
+
+	err = crypto_check_alg(&inst->alg);
+	if (err)
+		goto err;
+
+	inst->alg.cra_module = tmpl->module;
+
+	down_write(&crypto_alg_sem);
+
+	err = __crypto_register_alg(&inst->alg, &list);
+	if (err)
+		goto unlock;
+
+	hlist_add_head(&inst->list, &tmpl->instances);
+	inst->tmpl = tmpl;
+
+unlock:
+	up_write(&crypto_alg_sem);
+
+	crypto_remove_final(&list);
+
+err:
+	return err;
+}
+EXPORT_SYMBOL_GPL(crypto_register_instance);
+
+int crypto_init_spawn(struct crypto_spawn *spawn, struct crypto_alg *alg,
+		      struct crypto_instance *inst)
+{
+	int err = -EAGAIN;
+
+	spawn->inst = inst;
+
+	down_write(&crypto_alg_sem);
+	if (!crypto_is_moribund(alg)) {
+		list_add(&spawn->list, &alg->cra_users);
+		spawn->alg = alg;
+		err = 0;
+	}
+	up_write(&crypto_alg_sem);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(crypto_init_spawn);
+
+void crypto_drop_spawn(struct crypto_spawn *spawn)
+{
+	down_write(&crypto_alg_sem);
+	list_del(&spawn->list);
+	up_write(&crypto_alg_sem);
+}
+EXPORT_SYMBOL_GPL(crypto_drop_spawn);
+
+struct crypto_tfm *crypto_spawn_tfm(struct crypto_spawn *spawn)
+{
+	struct crypto_alg *alg;
+	struct crypto_alg *alg2;
+	struct crypto_tfm *tfm;
+
+	down_read(&crypto_alg_sem);
+	alg = spawn->alg;
+	alg2 = alg;
+	if (alg2)
+		alg2 = crypto_mod_get(alg2);
+	up_read(&crypto_alg_sem);
+
+	if (!alg2) {
+		if (alg)
+			crypto_shoot_alg(alg);
+		return ERR_PTR(-EAGAIN);
+	}
+
+	tfm = __crypto_alloc_tfm(alg, 0);
+	if (IS_ERR(tfm))
+		crypto_mod_put(alg);
+
+	return tfm;
+}
+EXPORT_SYMBOL_GPL(crypto_spawn_tfm);
+
+int crypto_register_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&crypto_chain, nb);
+}
+EXPORT_SYMBOL_GPL(crypto_register_notifier);
+
+int crypto_unregister_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&crypto_chain, nb);
+}
+EXPORT_SYMBOL_GPL(crypto_unregister_notifier);
+
+static int __init crypto_lowapi_init(void)
+{
+	printk(KERN_INFO "Initializing Cryptographic API\n");
+	crypto_init_proc();
+	return 0;
+}
+
+static void __exit crypto_lowapi_exit(void)
+{
+	crypto_exit_proc();
+}
+
+module_init(crypto_lowapi_init);
+module_exit(crypto_lowapi_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Low-level Cryptographic API");
diff --git a/crypto/proc.c b/crypto/proc.c
--- a/crypto/proc.c
+++ b/crypto/proc.c
@@ -113,3 +113,8 @@ void __init crypto_init_proc(void)
 	if (proc)
 		proc->proc_fops = &proc_crypto_ops;
 }
+
+void __exit crypto_exit_proc(void)
+{
+	remove_proc_entry("crypto", NULL);
+}
diff --git a/drivers/crypto/Kconfig b/drivers/crypto/Kconfig
--- a/drivers/crypto/Kconfig
+++ b/drivers/crypto/Kconfig
@@ -2,7 +2,7 @@ menu "Hardware crypto devices"
 
 config CRYPTO_DEV_PADLOCK
 	tristate "Support for VIA PadLock ACE"
-	depends on CRYPTO && X86_32
+	depends on X86_32
 	default m
 	help
 	  Some VIA processors come with an integrated crypto engine
@@ -26,6 +26,7 @@ config CRYPTO_DEV_PADLOCK
 config CRYPTO_DEV_PADLOCK_AES
 	tristate "PadLock driver for AES algorithm"
 	depends on CRYPTO_DEV_PADLOCK
+	select CRYPTO_LOWAPI
 	default m
 	help
 	  Use VIA PadLock for AES algorithm.
@@ -38,6 +39,7 @@ config CRYPTO_DEV_PADLOCK_AES
 config CRYPTO_DEV_PADLOCK_SHA
 	tristate "PadLock driver for SHA1 and SHA256 algorithms"
 	depends on CRYPTO_DEV_PADLOCK
+	select CRYPTO_LOWAPI
 	select CRYPTO_SHA1
 	select CRYPTO_SHA256
 	default m
diff --git a/include/crypto/lowapi.h b/include/crypto/lowapi.h
new file mode 100644
--- /dev/null
+++ b/include/crypto/lowapi.h
@@ -0,0 +1,65 @@
+/*
+ * Cryptographic API for algorithms (i.e., low-level API).
+ *
+ * Copyright (c) 2006 Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option) 
+ * any later version.
+ *
+ */
+#ifndef _CRYPTO_LOWAPI_H
+#define _CRYPTO_LOWAPI_H
+
+#include <linux/crypto.h>
+#include <linux/list.h>
+#include <linux/kernel.h>
+
+struct module;
+
+struct crypto_instance {
+	struct crypto_alg alg;
+
+	struct crypto_template *tmpl;
+	struct hlist_node list;
+
+	char __ctx[] __attribute__ ((__aligned__));
+};
+
+struct crypto_template {
+	struct list_head list;
+	struct hlist_head instances;
+	struct module *module;
+
+	struct crypto_instance *(*alloc)(void *param, unsigned int len);
+	void (*free)(struct crypto_instance *inst);
+
+	char name[CRYPTO_MAX_ALG_NAME];
+};
+
+struct crypto_spawn {
+	struct list_head list;
+	struct crypto_alg *alg;
+	struct crypto_instance *inst;
+};
+
+void crypto_mod_put(struct crypto_alg *alg);
+struct crypto_alg *crypto_alg_mod_lookup(const char *name, u32 type, u32 mask);
+
+int crypto_register_template(struct crypto_template *tmpl);
+void crypto_unregister_template(struct crypto_template *tmpl);
+struct crypto_template *crypto_lookup_template(const char *name);
+
+int crypto_init_spawn(struct crypto_spawn *spawn, struct crypto_alg *alg,
+		      struct crypto_instance *inst);
+void crypto_drop_spawn(struct crypto_spawn *spawn);
+struct crypto_tfm *crypto_spawn_tfm(struct crypto_spawn *spawn);
+
+static inline void *crypto_instance_ctx(struct crypto_instance *inst)
+{
+	return inst->__ctx;
+}
+
+#endif	/* _CRYPTO_LOWAPI_H */
+
