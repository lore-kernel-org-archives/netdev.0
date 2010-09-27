From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 27 Sep 2010 14:04:12 -0400
Message-ID: <20100927180412.GD11086@tuxdriver.com>
References: <20100927154408.55a28127.sfr@canb.auug.org.au>
 <AANLkTinHk82jM7Ztwb1aB1xb-hSLeg5Hb07mhYCaeszi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ohad Ben-Cohen <ohad@wizery.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinHk82jM7Ztwb1aB1xb-hSLeg5Hb07mhYCaeszi@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 05:55:42PM +0200, Ohad Ben-Cohen wrote:
> On Mon, Sep 27, 2010 at 7:44 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > Assembler messages:
> > Fatal error: can't create drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.o: No such file or directory
> > drivers/net/wireless/wl12xx/wl12xx_platform_data.c: In function 'wl12xx_get_platform_data':
> > drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: error: cannot open drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.gcno
> > drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: confused by earlier errors, bailing out
> >
> > Presumably caused by commit 61ee7007a5d61aa066076da578e8e8084e122d7d
> > ("wl12xx: add platform data passing support").
> >
> > I do my builds with a separate object directory (which may be a reason
> > you don't see this).
> 
> Thank you, Stephen.
> 
> I have just tried building with a separate object directory, and I was
> then able to reproduce it and fix it with:
> 
> From fb0d1dc5ce6c258b3ecb0a8997791a77be3c5307 Mon Sep 17 00:00:00 2001
> From: Ohad Ben-Cohen <ohad@wizery.com>
> Date: Mon, 27 Sep 2010 17:33:57 +0200
> Subject: [PATCH] wl12xx: fix separate-object-folder builds
> 
> Make this go away (happens when building with a separate object directory):
> 
> Assembler messages:
> Fatal error: can't create
> drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.o: No such file
> or directory
> drivers/net/wireless/wl12xx/wl12xx_platform_data.c: In function
> 'wl12xx_get_platform_data':
> drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: error: cannot
> open drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.gcno
> drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: confused by
> earlier errors, bailing out
> 
> Signed-off-by: Ohad Ben-Cohen <ohad@wizery.com>
> ---
>  drivers/net/wireless/Makefile                      |    2 +-
>  .../wireless/{wl12xx => }/wl12xx_platform_data.c   |    0
>  2 files changed, 1 insertions(+), 1 deletions(-)
>  rename drivers/net/wireless/{wl12xx => }/wl12xx_platform_data.c (100%)
> 
> diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
> index 85af697..0a64bd5 100644
> --- a/drivers/net/wireless/Makefile
> +++ b/drivers/net/wireless/Makefile
> @@ -51,6 +51,6 @@ obj-$(CONFIG_MAC80211_HWSIM)	+= mac80211_hwsim.o
> 
>  obj-$(CONFIG_WL12XX)	+= wl12xx/
>  # small builtin driver bit
> -obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+= wl12xx/wl12xx_platform_data.o
> +obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+= wl12xx_platform_data.o
> 
>  obj-$(CONFIG_IWM)	+= iwmc3200wifi/
> diff --git a/drivers/net/wireless/wl12xx/wl12xx_platform_data.c
> b/drivers/net/wireless/wl12xx_platform_data.c
> similarity index 100%
> rename from drivers/net/wireless/wl12xx/wl12xx_platform_data.c
> rename to drivers/net/wireless/wl12xx_platform_data.c

I like this version better, since it keeps the platform data with
the rest of the code:

>From f8ac84505927d0a1fd79994cefaad7abf9b2e693 Mon Sep 17 00:00:00 2001
From: John W. Linville <linville@tuxdriver.com>
Date: Mon, 27 Sep 2010 14:00:51 -0400
Subject: [PATCH] wl12xx: fix separate-object-folder builds

Make this go away (happens when building with a separate object
directory):

Assembler messages:
Fatal error: can't create drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.o: No such file or directory
drivers/net/wireless/wl12xx/wl12xx_platform_data.c: In function 'wl12xx_get_platform_data':
drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: error: cannot open drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.gcno
drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: confused by earlier errors, bailing out

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Signed-off-by: Ohad Ben-Cohen <ohad@wizery.com>
---
 drivers/net/wireless/Makefile        |    2 --
 drivers/net/wireless/wl12xx/Makefile |    3 +++
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index 85af697..5d4ce4d 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -50,7 +50,5 @@ obj-$(CONFIG_ATH_COMMON)	+= ath/
 obj-$(CONFIG_MAC80211_HWSIM)	+= mac80211_hwsim.o
 
 obj-$(CONFIG_WL12XX)	+= wl12xx/
-# small builtin driver bit
-obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+= wl12xx/wl12xx_platform_data.o
 
 obj-$(CONFIG_IWM)	+= iwmc3200wifi/
diff --git a/drivers/net/wireless/wl12xx/Makefile b/drivers/net/wireless/wl12xx/Makefile
index 078b439..0d334d6 100644
--- a/drivers/net/wireless/wl12xx/Makefile
+++ b/drivers/net/wireless/wl12xx/Makefile
@@ -16,3 +16,6 @@ wl1271-$(CONFIG_NL80211_TESTMODE)	+= wl1271_testmode.o
 obj-$(CONFIG_WL1271)	+= wl1271.o
 obj-$(CONFIG_WL1271_SPI)	+= wl1271_spi.o
 obj-$(CONFIG_WL1271_SDIO)	+= wl1271_sdio.o
+
+# small builtin driver bit
+obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+= wl12xx_platform_data.o
-- 
1.7.2.3


-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
