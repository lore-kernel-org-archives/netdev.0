From: =?UTF-8?B?QWxleGFuZGVyIFNoaXlhbg==?= <shc_work@mail.ru>
Subject: =?UTF-8?B?UmU6IFtQQVRDSCAyLzRdIHdsMTI1MTogbW92ZSBwb3dlciBHUElPIGhhbmRs?=
 =?UTF-8?B?aW5nIGludG8gdGhlIGRyaXZlcg==?=
Date: Sun, 27 Oct 2013 20:24:16 +0400
Message-ID: <1382891056.102746625@f315.i.mail.ru>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
 <1382890469-25286-3-git-send-email-sre@debian.org>
Reply-To: =?UTF-8?B?QWxleGFuZGVyIFNoaXlhbg==?= <shc_work@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TWFyayBSdXRsYW5k?= <mark.rutland@arm.com>,
 linux-doc@vger.kernel.org, =?UTF-8?B?VG9ueSBMaW5kZ3Jlbg==?= <tony@atomide.com>,
 =?UTF-8?B?UnVzc2VsbCBLaW5n?= <linux@arm.linux.org.uk>,
 =?UTF-8?B?U2FjaGluIEthbWF0?= <sachin.kamat@linaro.org>,
 =?UTF-8?B?U3RlcGhlbiBXYXJyZW4=?= <swarren@wwwdotorg.org>,
 =?UTF-8?B?U2ViYXN0aWFuIFJlaWNoZWw=?= <sre@ring0.de>,
 =?UTF-8?B?THVjaWFubyBDb2VsaG8=?= <luca@coelho.fi>, devicetree@vger.kernel.org,
 =?UTF-8?B?UGF3ZWwgTW9sbA==?= <pawel.moll@arm.com>,
 =?UTF-8?B?SWFuIENhbXBiZWxs?= <ijc+devicetree@hellion.org.uk>,
 =?UTF-8?B?Sm9obiBXLiBMaW52aWxsZQ==?= <linville@tuxdriver.com>,
 =?UTF-8?B?Um9iIEhlcnJpbmc=?= <rob.herring@calxeda.com>,
 =?UTF-8?B?QmlsbCBQZW1iZXJ0b24=?= <wfp5p@virginia.edu>,
 linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 =?UTF-8?B?R3JlZyBLcm9haC1IYXJ0bWFu?= <gregkh@linuxfoundation.org>,
 linux-wireless@vger.kernel.o
To: =?UTF-8?B?U2ViYXN0aWFuIFJlaWNoZWw=?= <sre@debian.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1382890469-25286-3-git-send-email-sre@debian.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> Move the power GPIO handling from the board code into
> the driver. This is a dependency for device tree support.
> 
> Signed-off-by: Sebastian Reichel <sre@debian.org>
> ---
>  arch/arm/mach-omap2/board-omap3pandora.c     |  2 ++
>  arch/arm/mach-omap2/board-rx51-peripherals.c | 11 ++--------
>  drivers/net/wireless/ti/wl1251/sdio.c        | 21 +++++++++++++-----
>  drivers/net/wireless/ti/wl1251/spi.c         | 33 ++++++++++++++++++----------
>  drivers/net/wireless/ti/wl1251/wl1251.h      |  2 +-
>  include/linux/wl12xx.h                       |  2 +-
>  6 files changed, 43 insertions(+), 28 deletions(-)
...
> diff --git a/include/linux/wl12xx.h b/include/linux/wl12xx.h
> index b516b4f..a9c723b 100644
> --- a/include/linux/wl12xx.h
> +++ b/include/linux/wl12xx.h
> @@ -49,7 +49,7 @@ enum {
>  };
>  
>  struct wl1251_platform_data {
> -	void (*set_power)(bool enable);
> +	int power_gpio;
>  	/* SDIO only: IRQ number if WLAN_IRQ line is used, 0 for SDIO IRQs */
>  	int irq;
>  	bool use_eeprom;
> -- 

What a reason for not using regulator API here with GPIO-based regulator?

---
