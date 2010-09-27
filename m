From: Ohad Ben-Cohen <ohad@wizery.com>
Subject: Re: linux-next: build failure after merge of the final tree (net tree related)
Date: Mon, 27 Sep 2010 17:55:42 +0200
Message-ID: <AANLkTinHk82jM7Ztwb1aB1xb-hSLeg5Hb07mhYCaeszi@mail.gmail.com>
References: <20100927154408.55a28127.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100927154408.55a28127.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 7:44 AM, Stephen Rothwell <sfr@canb.auug.org.au=
> wrote:
> Assembler messages:
> Fatal error: can't create drivers/net/wireless/wl12xx/.tmp_wl12xx_pla=
tform_data.o: No such file or directory
> drivers/net/wireless/wl12xx/wl12xx_platform_data.c: In function 'wl12=
xx_get_platform_data':
> drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: error: cannot =
open drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.gcno
> drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: confused by ea=
rlier errors, bailing out
>
> Presumably caused by commit 61ee7007a5d61aa066076da578e8e8084e122d7d
> ("wl12xx: add platform data passing support").
>
> I do my builds with a separate object directory (which may be a reaso=
n
> you don't see this).

Thank you, Stephen.

I have just tried building with a separate object directory, and I was
then able to reproduce it and fix it with:

=46rom fb0d1dc5ce6c258b3ecb0a8997791a77be3c5307 Mon Sep 17 00:00:00 200=
1
=46rom: Ohad Ben-Cohen <ohad@wizery.com>
Date: Mon, 27 Sep 2010 17:33:57 +0200
Subject: [PATCH] wl12xx: fix separate-object-folder builds

Make this go away (happens when building with a separate object directo=
ry):

Assembler messages:
=46atal error: can't create
drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.o: No such file
or directory
drivers/net/wireless/wl12xx/wl12xx_platform_data.c: In function
'wl12xx_get_platform_data':
drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: error: cannot
open drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.gcno
drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: confused by
earlier errors, bailing out

Signed-off-by: Ohad Ben-Cohen <ohad@wizery.com>
---
 drivers/net/wireless/Makefile                      |    2 +-
 .../wireless/{wl12xx =3D> }/wl12xx_platform_data.c   |    0
 2 files changed, 1 insertions(+), 1 deletions(-)
 rename drivers/net/wireless/{wl12xx =3D> }/wl12xx_platform_data.c (100=
%)

diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makef=
ile
index 85af697..0a64bd5 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -51,6 +51,6 @@ obj-$(CONFIG_MAC80211_HWSIM)	+=3D mac80211_hwsim.o

 obj-$(CONFIG_WL12XX)	+=3D wl12xx/
 # small builtin driver bit
-obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+=3D wl12xx/wl12xx_platform_data.o
+obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+=3D wl12xx_platform_data.o

 obj-$(CONFIG_IWM)	+=3D iwmc3200wifi/
diff --git a/drivers/net/wireless/wl12xx/wl12xx_platform_data.c
b/drivers/net/wireless/wl12xx_platform_data.c
similarity index 100%
rename from drivers/net/wireless/wl12xx/wl12xx_platform_data.c
rename to drivers/net/wireless/wl12xx_platform_data.c
--=20
1.7.0.4


>
> I have reverted that commit for today (and commits
> 09cecc340b3b4d9960b039c0f576548bbf857f5a ("wl1271: take irq info from
> private board data") and 15cea99306ae14ce5f7c3d3989bcc17202e2b0be
> ("wl1271: make ref_clock configurable by board") which follow it).
> --
> Cheers,
> Stephen Rothwell =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sfr@canb.auug=
=2Eorg.au
> http://www.canb.auug.org.au/~sfr/
>
