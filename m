From: akpm@osdl.org
Subject: [patch 1/3] fix buggy IEEE80211_CRYPT_* selects
Date: Fri, 04 Mar 2005 04:37:16 -0800
Message-ID: <200503041237.j24Cbb69026470@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, bunk@stusta.de
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Adrian Bunk <bunk@stusta.de>

Some of the options that needlessly wrote in their help text which options
they do select (patch already sent) didn't obey the most important rule of
select

  If you select something, you have to ensure that the dependencies
  of what you do select are fulfilled.

resulting in the following compile error:

<--  snip  -->

...
  LD      .tmp_vmlinux1
crypto/built-in.o(.init.text+0x31b): In function `aes_init':
: undefined reference to `crypto_register_alg'
crypto/built-in.o(.init.text+0x326): In function `michael_mic_init':
: undefined reference to `crypto_register_alg'
crypto/built-in.o(.exit.text+0x6): In function `aes_fini':
: undefined reference to `crypto_unregister_alg'
crypto/built-in.o(.exit.text+0x16): In function `michael_mic_exit':
: undefined reference to `crypto_unregister_alg'
net/built-in.o(.text+0x5ba52): In function `ieee80211_ccmp_init':
: undefined reference to `crypto_alloc_tfm'
net/built-in.o(.text+0x5ba94): In function `ieee80211_ccmp_init':
: undefined reference to `crypto_free_tfm'
net/built-in.o(.text+0x5bab7): In function `ieee80211_ccmp_deinit':
: undefined reference to `crypto_free_tfm'
net/built-in.o(.text+0x5c5c2): In function `ieee80211_tkip_init':
: undefined reference to `crypto_alloc_tfm'
net/built-in.o(.text+0x5c5d5): In function `ieee80211_tkip_init':
: undefined reference to `crypto_alloc_tfm'
net/built-in.o(.text+0x5c623): In function `ieee80211_tkip_init':
: undefined reference to `crypto_free_tfm'
net/built-in.o(.text+0x5c62a): In function `ieee80211_tkip_init':
: undefined reference to `crypto_free_tfm'
net/built-in.o(.text+0x5c65e): In function `ieee80211_tkip_deinit':
: undefined reference to `crypto_free_tfm'
net/built-in.o(.text+0x5c665): In function `ieee80211_tkip_deinit':
: undefined reference to `crypto_free_tfm'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->

This patch adds the missing selects of CRYPTO.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/ieee80211/Kconfig |    2 ++
 1 files changed, 2 insertions(+)

diff -puN net/ieee80211/Kconfig~fix-buggy-ieee80211_crypt_-selects net/ieee80211/Kconfig
--- 25/net/ieee80211/Kconfig~fix-buggy-ieee80211_crypt_-selects	2005-02-28 14:49:54.000000000 -0800
+++ 25-akpm/net/ieee80211/Kconfig	2005-02-28 14:49:54.000000000 -0800
@@ -44,6 +44,7 @@ config IEEE80211_CRYPT_WEP
 config IEEE80211_CRYPT_CCMP
 	tristate "IEEE 802.11i CCMP support"
 	depends on IEEE80211
+	select CRYPTO
 	select CRYPTO_AES
 	---help---
 	Include software based cipher suites in support of IEEE 802.11i 
@@ -56,6 +57,7 @@ config IEEE80211_CRYPT_CCMP
 config IEEE80211_CRYPT_TKIP
 	tristate "IEEE 802.11i TKIP encryption"
 	depends on IEEE80211
+	select CRYPTO
 	select CRYPTO_MICHAEL_MIC
 	---help---
 	Include software based cipher suites in support of IEEE 802.11i 
_
