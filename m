From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 27 Sep 2010 15:44:08 -0400
Message-ID: <20100927194408.GG11086@tuxdriver.com>
References: <20100927154408.55a28127.sfr@canb.auug.org.au>
 <AANLkTinHk82jM7Ztwb1aB1xb-hSLeg5Hb07mhYCaeszi@mail.gmail.com>
 <20100927180412.GD11086@tuxdriver.com>
 <20100927.111818.149846920.davem@davemloft.net>
 <20100927182546.GE11086@tuxdriver.com>
 <AANLkTi=YHhRWFix1QDuEnRW7r_UaNtp6KSL9uLdUzdqM@mail.gmail.com>
 <20100927184445.GF11086@tuxdriver.com>
 <AANLkTi=2KqQb+gvuigxb+-tSzawx7=q3HtnkkE6t_4XF@mail.gmail.com>
 <AANLkTim9nHmhNLmECnYk-OHYmyk96tz65kd=ybz24M3Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ohad Ben-Cohen <ohad@wizery.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTim9nHmhNLmECnYk-OHYmyk96tz65kd=ybz24M3Y@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 09:06:09PM +0200, Ohad Ben-Cohen wrote:
> On Mon, Sep 27, 2010 at 9:01 PM, Ohad Ben-Cohen <ohad@wizery.com> wro=
te:
> > On Mon, Sep 27, 2010 at 8:44 PM, John W. Linville
> > <linville@tuxdriver.com> wrote:
> >> On Mon, Sep 27, 2010 at 08:38:50PM +0200, Ohad Ben-Cohen wrote:
> >>> On Mon, Sep 27, 2010 at 8:25 PM, John W. Linville
> >>> <linville@tuxdriver.com> wrote:
> >>> >> BTW, if this fuglet going to work if the driver is built modul=
ar?
> >>> >>
> >>> >> The idea of this things seems to be to allow arch platform cod=
e to call
> >>> >> into it to set things. =A0Such calls from arch platform code a=
re going
> >>> >> to be "obj-y"
> >>> >>
> >>> >> So if this is built into the modular driver, I can't see how i=
t
> >>> >> can work.
> >>> >
> >>> > Dave is right -- these Kconfig dependencies (or lack thereof) s=
eem
> >>> > to be wrong.
> >>>
> >>> This is why I had to put it in drivers/net/wireless/Makefile (in =
both
> >>> the original patch and in the fix I sent earlier) and not in
> >>> drivers/net/wireless/wl12xx/Makefile (as it was in the fix that D=
ave
> >>> was referring to).
> >>>
> >>> This way it works with a modular driver.
> >>
> >> That doesn't seem very helpful if someone selects
> >>
> >> CONFIG_MACH_OMAP_ZOOM2=3Dy
> >> CONFIG_WL12XX_PLATFORM_DATA=3Dn
>=20
>=20
> That's a good point (it's a separate issue); we need to have a select=
 there.
>=20
> I'll send a patch.

No, maybe you don't need it -- the bool line by itself means there
is no menu item.  So the default y does the job of selecting it all
the time (which kinda sucks for non-OMAP)...

> >>
> >
> > CONFIG_WL12XX_PLATFORM_DATA is selected automatically if the releva=
nt
> > driver is selected (this is independent of the underlying arch/boar=
d):
> >
> > config WL12XX_PLATFORM_DATA
> > =A0 =A0 =A0 =A0bool
> > =A0 =A0 =A0 =A0depends on WL1271_SDIO !=3D n
> > =A0 =A0 =A0 =A0default y
> >
> > All we have to make sure is that it will be compiled built-in. If w=
e
> > use drivers/net/wireless/wl12xx/Makefile, and we build a modular
> > wl1271_sdio, it won't (despite it being selected as y).

I don't understand this part.  FWIW, Kconfig is not a strength for me.
But...

> > That's why I put it in drivers/net/wireless/Makefile.

Can't we do this?  It seems to work (i.e. the symbols from
wl12xx_platform_data.o end-up in built-in.o).

=46rom d8ddd0ebe8ae3791ba9c76a506bfcdd60be40f5b Mon Sep 17 00:00:00 200=
1
=46rom: John W. Linville <linville@tuxdriver.com>
Date: Mon, 27 Sep 2010 14:00:51 -0400
Subject: [PATCH] wl12xx: fix separate-object-folder builds

Make this go away (happens when building with a separate object
directory):

Assembler messages:
=46atal error: can't create drivers/net/wireless/wl12xx/.tmp_wl12xx_pla=
tform_data.o: No such file or directory
drivers/net/wireless/wl12xx/wl12xx_platform_data.c: In function 'wl12xx=
_get_platform_data':
drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: error: cannot op=
en drivers/net/wireless/wl12xx/.tmp_wl12xx_platform_data.gcno
drivers/net/wireless/wl12xx/wl12xx_platform_data.c:28: confused by earl=
ier errors, bailing out

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Signed-off-by: Ohad Ben-Cohen <ohad@wizery.com>
---
 drivers/net/wireless/Makefile        |    3 +--
 drivers/net/wireless/wl12xx/Makefile |    3 +++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makef=
ile
index 85af697..a13a602 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -50,7 +50,6 @@ obj-$(CONFIG_ATH_COMMON)	+=3D ath/
 obj-$(CONFIG_MAC80211_HWSIM)	+=3D mac80211_hwsim.o
=20
 obj-$(CONFIG_WL12XX)	+=3D wl12xx/
-# small builtin driver bit
-obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+=3D wl12xx/wl12xx_platform_data.o
+obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+=3D wl12xx/
=20
 obj-$(CONFIG_IWM)	+=3D iwmc3200wifi/
diff --git a/drivers/net/wireless/wl12xx/Makefile b/drivers/net/wireles=
s/wl12xx/Makefile
index 078b439..0d334d6 100644
--- a/drivers/net/wireless/wl12xx/Makefile
+++ b/drivers/net/wireless/wl12xx/Makefile
@@ -16,3 +16,6 @@ wl1271-$(CONFIG_NL80211_TESTMODE)	+=3D wl1271_testmod=
e.o
 obj-$(CONFIG_WL1271)	+=3D wl1271.o
 obj-$(CONFIG_WL1271_SPI)	+=3D wl1271_spi.o
 obj-$(CONFIG_WL1271_SDIO)	+=3D wl1271_sdio.o
+
+# small builtin driver bit
+obj-$(CONFIG_WL12XX_PLATFORM_DATA)	+=3D wl12xx_platform_data.o
--=20
1.7.2.3


--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
