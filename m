From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: fix error handling in *_read_adapter_info()
Date: Thu, 16 Jun 2016 15:13:51 +0000 (UTC)
Message-ID: <20160616151351.4AD026141C@smtp.codeaurora.org>
References: <1464622792-1749047-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Taehee Yoo <ap420073@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464622792-1749047-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:
> There are nine copies of the _rtl88ee_read_adapter_info() function,
> and most but not all of them cause a build warning in some configurations:
> 
> rtl8192de/hw.c: In function '_rtl92de_read_adapter_info':
> rtl8192de/hw.c:1767:12: error: 'hwinfo' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> rtl8723ae/hw.c: In function '_rtl8723e_read_adapter_info.constprop':
> rtlwifi/rtl8723ae/hw.c:1654:12: error: 'hwinfo' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> The problem is that when rtlefuse->epromtype is something other than
> EEPROM_BOOT_EFUSE, the rest of the function uses undefined data, resulting
> in random behavior later.
> 
> Apparently, in some drivers, the problem was already found and fixed
> but the fix did not make it into the others.
> 
> This picks one approach to deal with the problem and applies identical
> code to all 9 files, to simplify the later consolidation of those.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks, 1 patch applied to wireless-drivers-next.git:

5345ea6a4bfb rtlwifi: fix error handling in *_read_adapter_info()

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9141721/
