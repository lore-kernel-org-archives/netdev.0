From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: ieee80211_crypt_wep.c:(.text+0x90dd7): undefined reference to `crypto_free_tfm'
Date: Sat, 8 Nov 2008 13:13:30 +0300
Message-ID: <20081108101330.GA19184@ioremap.net>
References: <20081108075437.GA312@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Zhu Yi <yi.zhu@intel.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:54812 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbYKHKNc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Nov 2008 05:13:32 -0500
Content-Disposition: inline
In-Reply-To: <20081108075437.GA312@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ingo.

On Sat, Nov 08, 2008 at 08:54:37AM +0100, Ingo Molnar (mingo@elte.hu) wrote:
> not sure whether this has been reported before, but with latest upstream 
> i get this new build failure with certain (rare, randconfig) configs:
> 
>  net/built-in.o: In function `prism2_wep_deinit':
>  ieee80211_crypt_wep.c:(.text+0x90dd7): undefined reference to `crypto_free_tfm'
>  ieee80211_crypt_wep.c:(.text+0x90de3): undefined reference to `crypto_free_tfm'
>  net/built-in.o: In function `prism2_wep_init':
>  ieee80211_crypt_wep.c:(.text+0x90fab): undefined reference to `crypto_alloc_base'
>  ieee80211_crypt_wep.c:(.text+0x90fc9): undefined reference to `crypto_alloc_base'
>  ieee80211_crypt_wep.c:(.text+0x91007): undefined reference to `crypto_free_tfm'
>  ieee80211_crypt_wep.c:(.text+0x91031): undefined reference to `crypto_free_tfm'

The problem is:

> CONFIG_IEEE80211=y
> CONFIG_IEEE80211_CRYPT_WEP=y

> CONFIG_CRYPTO=m

While
config IEEE80211_CRYPT_WEP
        tristate "IEEE 802.11 WEP encryption (802.1x)"
	depends on IEEE80211
	select CRYPTO

Looks like select does not force 'yes' instead of 'module'?

-- 
	Evgeniy Polyakov
