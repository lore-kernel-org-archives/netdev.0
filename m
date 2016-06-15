From: Jes Sorensen <Jes.Sorensen@redhat.com>
Subject: Re: [PATCH] rtlwifi: use s8 instead of char
Date: Wed, 15 Jun 2016 17:10:51 -0400
Message-ID: <wrfjbn32taxw.fsf@redhat.com>
References: <20160615210318.4130648-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076AbcFOVKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 17:10:52 -0400
In-Reply-To: <20160615210318.4130648-1-arnd@arndb.de> (Arnd Bergmann's message
	of "Wed, 15 Jun 2016 23:03:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:
> Compiling the rtlwifi drivers for ARM with gcc -Wextra warns about lots of
> incorrect code that results from 'char' being unsigned here, e.g.
>
> realtek/rtlwifi/rc.c:113:18: error: comparison is always true due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8188ee/dm.c:1070:22: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192ce/trx.c:54:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192cu/mac.c:601:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192de/trx.c:53:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192ee/phy.c:1268:12: error: comparison is always true due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192se/rf.c:150:20: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8723be/dm.c:877:29: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8723be/phy.c:386:16: error: comparison is always true due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8821ae/dm.c:1514:38: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8821ae/phy.c:1558:11: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8821ae/phy.c:386:24: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8821ae/trx.c:55:12: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/stats.c:31:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
>
> This patch changes all uses of 'char' in this driver that refer to
> 8-bit integers to use 's8' instead, which is signed on all architectures.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |  6 +-
>  .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       |  2 +-
>  .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |  4 +-
>  drivers/net/wireless/realtek/rtlwifi/rc.c          |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8188ee/dm.c    |  4 +-
>  .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.c   |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.h   |  4 +-
>  .../wireless/realtek/rtlwifi/rtl8192c/dm_common.h  |  2 +-
>  .../wireless/realtek/rtlwifi/rtl8192c/phy_common.c |  4 +-
>  .../wireless/realtek/rtlwifi/rtl8192c/phy_common.h |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192ce/phy.h   |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.c   |  6 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.h   |  4 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192cu/mac.c   |  6 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192cu/mac.h   |  4 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192de/phy.c   |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192de/phy.h   |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192de/trx.c   |  6 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192de/trx.h   |  4 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192ee/phy.c   | 10 ++--
>  .../net/wireless/realtek/rtlwifi/rtl8192ee/phy.h   |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.c   |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.h   |  4 +-
>  .../net/wireless/realtek/rtlwifi/rtl8192se/rf.c    |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8723ae/trx.h   |  4 +-
>  .../net/wireless/realtek/rtlwifi/rtl8723be/dm.c    |  4 +-
>  .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |  4 +-
>  .../net/wireless/realtek/rtlwifi/rtl8723be/trx.c   |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8723be/trx.h   |  8 +--
>  .../net/wireless/realtek/rtlwifi/rtl8821ae/dm.c    |  4 +-
>  .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   | 48 +++++++--------
>  .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.h   |  2 +-
>  .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.c   | 12 ++--
>  .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.h   | 10 ++--
>  drivers/net/wireless/realtek/rtlwifi/stats.c       |  6 +-
>  drivers/net/wireless/realtek/rtlwifi/stats.h       |  4 +-
>  drivers/net/wireless/realtek/rtlwifi/wifi.h        | 68
> +++++++++++----------

Arnd,

rtlwifi and rtl8xxxu are two distinct drivers managed by different
people. I'd be really nice if you could split this into a per driver
patch.

That said, the use of char in rtl8xxxu is all as a flag indicator, so I
don't think the s/char/s8/ conversion is justified. I used char rather
than ugly bool to reduce the size of the struct.

Cheers,
Jes
