From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macsec: fix crypto Kconfig dependency
Date: Sun, 17 Apr 2016 18:52:09 -0400 (EDT)
Message-ID: <20160417.185209.2274621456744786466.davem@davemloft.net>
References: <1460884918-2879720-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, hannes@stressinduktion.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbcDQWwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2016 18:52:22 -0400
In-Reply-To: <1460884918-2879720-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Sun, 17 Apr 2016 11:19:55 +0200

> The new MACsec driver uses the AES crypto algorithm, but can be configured
> even if CONFIG_CRYPTO is disabled, leading to a build error:
> 
> warning: (MAC80211 && MACSEC) selects CRYPTO_GCM which has unmet direct dependencies (CRYPTO)
> warning: (BT && CEPH_LIB && INET && MAC802154 && MAC80211 && BLK_DEV_RBD && MACSEC && AIRO_CS && LIBIPW && HOSTAP && USB_WUSB && RTLLIB_CRYPTO_CCMP && FS_ENCRYPTION && EXT4_ENCRYPTION && CEPH_FS && BIG_KEYS && ENCRYPTED_KEYS) selects CRYPTO_AES which has unmet direct dependencies (CRYPTO)
> crypto/built-in.o: In function `gcm_enc_copy_hash':
> aes_generic.c:(.text+0x2b8): undefined reference to `crypto_xor'
> aes_generic.c:(.text+0x2dc): undefined reference to `scatterwalk_map_and_copy'
> 
> This adds an explicit 'select CRYPTO' statement the way that other
> drivers handle it.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")

Applied, thanks Arnd.
