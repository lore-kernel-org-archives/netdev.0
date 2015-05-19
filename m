From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH] mac802154: select CRYPTO when needed
Date: Tue, 19 May 2015 14:57:08 +0200
Message-ID: <555B3324.6010803@osg.samsung.com>
References: <4189396.LhxDXkIPfr@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>,
	Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:57199 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755691AbbESM5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 08:57:14 -0400
In-Reply-To: <4189396.LhxDXkIPfr@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 19/05/15 14:18, Arnd Bergmann wrote:
> The mac802154 subsystem uses functions from the crypto layer and correctly
> selects the individual crypto algorithms, but fails to build when the
> crypto layer is disabled altogether:
>
> crypto/built-in.o: In function `crypto_ctr_free':
> :(.text+0x80): undefined reference to `crypto_drop_spawn'
> crypto/built-in.o: In function `crypto_rfc3686_free':
> :(.text+0xac): undefined reference to `crypto_drop_spawn'
> crypto/built-in.o: In function `crypto_ctr_crypt':
> :(.text+0x2f0): undefined reference to `blkcipher_walk_virt_block'
> :(.text+0x2f8): undefined reference to `crypto_inc'
>
> To solve that, this patch also selects the core crypto code,
> like all other users of that code do.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Found in ARM randconfig testing
>
> diff --git a/net/mac802154/Kconfig b/net/mac802154/Kconfig
> index aa462b480a39..b355989c63b3 100644
> --- a/net/mac802154/Kconfig
> +++ b/net/mac802154/Kconfig
> @@ -1,6 +1,7 @@
>   config MAC802154
>   	tristate "Generic IEEE 802.15.4 Soft Networking Stack (mac802154)"
>   	depends on IEEE802154
> +	select CRYPTO
>   	select CRC_CCITT
>   	select CRYPTO_AUTHENC
>   	select CRYPTO_CCM

Good point. I thought that would have been pulled in by CRYPTO_* 
automatically. Nicely spotted.

Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>

regards
Stefan Schmidt
