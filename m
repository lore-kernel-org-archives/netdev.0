From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-10-26
Date: Fri, 26 Oct 2012 11:21:13 -0400
Message-ID: <20121026152112.GB16104@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/04w6evG8XlLl3ft"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 330ee00412bbaefa7d0597a1bed7804e818ba91c

Dave,

This is a batch of fixes intended for the 3.7 stream.

Bing Zhao brings two mwifiex fixes, both continuing to fix some scanning
failure cases.

Christian Lamparter provides an rtlwifi fix to properly propogate an
error code.

Felix Fietkau reverts a previous fix that was improperly reducing Tx
power for some devices.  This one looks big, but it is mostly just
changes to a table of initialization values.

Larry Finger provides a b43 version of an earlier b43legacy fix to
avoid and oops when removing the modules after failing to load firmware.

Mohammed Shafi Shajakhan provides a new device ID for ath9k_htc.

Stanislaw Gruszka gives us an rt2x00 fix to avoide a WARNING during
resume, as described in kernel.org bug 48041.

Yuanhan Liu fixes a potential NULL dereference in brcmfmac.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3da3fff8006c608f19a51859d44ba47ca8b41461:

  tilegx: fix some issues in the SW TSO support (2012-10-26 03:50:08 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 330ee00412bbaefa7d0597a1bed7804e818ba91c:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-10-26 10:32:13 -0400)

----------------------------------------------------------------

Bing Zhao (2):
      mwifiex: return -EBUSY if specific scan request cannot be honored
      mwifiex: clean up scan state on error

Christian Lamparter (1):
      rtlwifi: pass rx setup error code to caller

Felix Fietkau (1):
      Revert "ath9k_hw: Updated AR9003 tx gain table for 5GHz"

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      b43: Fix oops on unload when firmware not found

Mohammed Shafi Shajakhan (1):
      ath9k_htc: Add PID/VID for a Ubiquiti WiFiStation

Stanislaw Gruszka (1):
      rt2x00: usb: fix reset resume

Yuanhan Liu (1):
      brcmfmac: fix potential NULL dereference

 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   | 164 ++++++++++-------=
----
 drivers/net/wireless/ath/ath9k/hif_usb.c           |   1 +
 drivers/net/wireless/b43/main.c                    |   4 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   2 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   7 +-
 drivers/net/wireless/mwifiex/scan.c                |  13 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |   1 +
 drivers/net/wireless/rt2x00/rt2800usb.c            |   1 +
 drivers/net/wireless/rt2x00/rt73usb.c              |   1 +
 drivers/net/wireless/rtlwifi/usb.c                 |   2 +-
 10 files changed, 102 insertions(+), 94 deletions(-)
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h b/drivers=
/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
index 89bf94d..6f7cf49 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
@@ -534,107 +534,107 @@ static const u32 ar9300_2p2_baseband_core[][2] =3D {
=20
 static const u32 ar9300Modes_high_power_tx_gain_table_2p2[][5] =3D {
 	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
-	{0x0000a2dc, 0x000cfff0, 0x000cfff0, 0x03aaa352, 0x03aaa352},
-	{0x0000a2e0, 0x000f0000, 0x000f0000, 0x03ccc584, 0x03ccc584},
-	{0x0000a2e4, 0x03f00000, 0x03f00000, 0x03f0f800, 0x03f0f800},
+	{0x0000a2dc, 0x00033800, 0x00033800, 0x03aaa352, 0x03aaa352},
+	{0x0000a2e0, 0x0003c000, 0x0003c000, 0x03ccc584, 0x03ccc584},
+	{0x0000a2e4, 0x03fc0000, 0x03fc0000, 0x03f0f800, 0x03f0f800},
 	{0x0000a2e8, 0x00000000, 0x00000000, 0x03ff0000, 0x03ff0000},
 	{0x0000a410, 0x000050d9, 0x000050d9, 0x000050d9, 0x000050d9},
 	{0x0000a500, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a504, 0x06000003, 0x06000003, 0x04000002, 0x04000002},
 	{0x0000a508, 0x0a000020, 0x0a000020, 0x08000004, 0x08000004},
 	{0x0000a50c, 0x10000023, 0x10000023, 0x0b000200, 0x0b000200},
-	{0x0000a510, 0x15000028, 0x15000028, 0x0f000202, 0x0f000202},
-	{0x0000a514, 0x1b00002b, 0x1b00002b, 0x12000400, 0x12000400},
-	{0x0000a518, 0x1f020028, 0x1f020028, 0x16000402, 0x16000402},
-	{0x0000a51c, 0x2502002b, 0x2502002b, 0x19000404, 0x19000404},
-	{0x0000a520, 0x2a04002a, 0x2a04002a, 0x1c000603, 0x1c000603},
-	{0x0000a524, 0x2e06002a, 0x2e06002a, 0x21000a02, 0x21000a02},
-	{0x0000a528, 0x3302202d, 0x3302202d, 0x25000a04, 0x25000a04},
-	{0x0000a52c, 0x3804202c, 0x3804202c, 0x28000a20, 0x28000a20},
-	{0x0000a530, 0x3c06202c, 0x3c06202c, 0x2c000e20, 0x2c000e20},
-	{0x0000a534, 0x4108202d, 0x4108202d, 0x30000e22, 0x30000e22},
-	{0x0000a538, 0x4506402d, 0x4506402d, 0x34000e24, 0x34000e24},
-	{0x0000a53c, 0x4906222d, 0x4906222d, 0x38001640, 0x38001640},
-	{0x0000a540, 0x4d062231, 0x4d062231, 0x3c001660, 0x3c001660},
-	{0x0000a544, 0x50082231, 0x50082231, 0x3f001861, 0x3f001861},
-	{0x0000a548, 0x5608422e, 0x5608422e, 0x43001a81, 0x43001a81},
-	{0x0000a54c, 0x5a08442e, 0x5a08442e, 0x47001a83, 0x47001a83},
-	{0x0000a550, 0x5e0a4431, 0x5e0a4431, 0x4a001c84, 0x4a001c84},
-	{0x0000a554, 0x640a4432, 0x640a4432, 0x4e001ce3, 0x4e001ce3},
-	{0x0000a558, 0x680a4434, 0x680a4434, 0x52001ce5, 0x52001ce5},
-	{0x0000a55c, 0x6c0a6434, 0x6c0a6434, 0x56001ce9, 0x56001ce9},
-	{0x0000a560, 0x6f0a6633, 0x6f0a6633, 0x5a001ceb, 0x5a001ceb},
-	{0x0000a564, 0x730c6634, 0x730c6634, 0x5d001eec, 0x5d001eec},
-	{0x0000a568, 0x730c6634, 0x730c6634, 0x5d001eec, 0x5d001eec},
-	{0x0000a56c, 0x730c6634, 0x730c6634, 0x5d001eec, 0x5d001eec},
-	{0x0000a570, 0x730c6634, 0x730c6634, 0x5d001eec, 0x5d001eec},
-	{0x0000a574, 0x730c6634, 0x730c6634, 0x5d001eec, 0x5d001eec},
-	{0x0000a578, 0x730c6634, 0x730c6634, 0x5d001eec, 0x5d001eec},
-	{0x0000a57c, 0x730c6634, 0x730c6634, 0x5d001eec, 0x5d001eec},
+	{0x0000a510, 0x16000220, 0x16000220, 0x0f000202, 0x0f000202},
+	{0x0000a514, 0x1c000223, 0x1c000223, 0x12000400, 0x12000400},
+	{0x0000a518, 0x21002220, 0x21002220, 0x16000402, 0x16000402},
+	{0x0000a51c, 0x27002223, 0x27002223, 0x19000404, 0x19000404},
+	{0x0000a520, 0x2b022220, 0x2b022220, 0x1c000603, 0x1c000603},
+	{0x0000a524, 0x2f022222, 0x2f022222, 0x21000a02, 0x21000a02},
+	{0x0000a528, 0x34022225, 0x34022225, 0x25000a04, 0x25000a04},
+	{0x0000a52c, 0x3a02222a, 0x3a02222a, 0x28000a20, 0x28000a20},
+	{0x0000a530, 0x3e02222c, 0x3e02222c, 0x2c000e20, 0x2c000e20},
+	{0x0000a534, 0x4202242a, 0x4202242a, 0x30000e22, 0x30000e22},
+	{0x0000a538, 0x4702244a, 0x4702244a, 0x34000e24, 0x34000e24},
+	{0x0000a53c, 0x4b02244c, 0x4b02244c, 0x38001640, 0x38001640},
+	{0x0000a540, 0x4e02246c, 0x4e02246c, 0x3c001660, 0x3c001660},
+	{0x0000a544, 0x52022470, 0x52022470, 0x3f001861, 0x3f001861},
+	{0x0000a548, 0x55022490, 0x55022490, 0x43001a81, 0x43001a81},
+	{0x0000a54c, 0x59022492, 0x59022492, 0x47001a83, 0x47001a83},
+	{0x0000a550, 0x5d022692, 0x5d022692, 0x4a001c84, 0x4a001c84},
+	{0x0000a554, 0x61022892, 0x61022892, 0x4e001ce3, 0x4e001ce3},
+	{0x0000a558, 0x65024890, 0x65024890, 0x52001ce5, 0x52001ce5},
+	{0x0000a55c, 0x69024892, 0x69024892, 0x56001ce9, 0x56001ce9},
+	{0x0000a560, 0x6e024c92, 0x6e024c92, 0x5a001ceb, 0x5a001ceb},
+	{0x0000a564, 0x74026e92, 0x74026e92, 0x5d001eec, 0x5d001eec},
+	{0x0000a568, 0x74026e92, 0x74026e92, 0x5d001eec, 0x5d001eec},
+	{0x0000a56c, 0x74026e92, 0x74026e92, 0x5d001eec, 0x5d001eec},
+	{0x0000a570, 0x74026e92, 0x74026e92, 0x5d001eec, 0x5d001eec},
+	{0x0000a574, 0x74026e92, 0x74026e92, 0x5d001eec, 0x5d001eec},
+	{0x0000a578, 0x74026e92, 0x74026e92, 0x5d001eec, 0x5d001eec},
+	{0x0000a57c, 0x74026e92, 0x74026e92, 0x5d001eec, 0x5d001eec},
 	{0x0000a580, 0x00800000, 0x00800000, 0x00800000, 0x00800000},
 	{0x0000a584, 0x06800003, 0x06800003, 0x04800002, 0x04800002},
 	{0x0000a588, 0x0a800020, 0x0a800020, 0x08800004, 0x08800004},
 	{0x0000a58c, 0x10800023, 0x10800023, 0x0b800200, 0x0b800200},
-	{0x0000a590, 0x15800028, 0x15800028, 0x0f800202, 0x0f800202},
-	{0x0000a594, 0x1b80002b, 0x1b80002b, 0x12800400, 0x12800400},
-	{0x0000a598, 0x1f820028, 0x1f820028, 0x16800402, 0x16800402},
-	{0x0000a59c, 0x2582002b, 0x2582002b, 0x19800404, 0x19800404},
-	{0x0000a5a0, 0x2a84002a, 0x2a84002a, 0x1c800603, 0x1c800603},
-	{0x0000a5a4, 0x2e86002a, 0x2e86002a, 0x21800a02, 0x21800a02},
-	{0x0000a5a8, 0x3382202d, 0x3382202d, 0x25800a04, 0x25800a04},
-	{0x0000a5ac, 0x3884202c, 0x3884202c, 0x28800a20, 0x28800a20},
-	{0x0000a5b0, 0x3c86202c, 0x3c86202c, 0x2c800e20, 0x2c800e20},
-	{0x0000a5b4, 0x4188202d, 0x4188202d, 0x30800e22, 0x30800e22},
-	{0x0000a5b8, 0x4586402d, 0x4586402d, 0x34800e24, 0x34800e24},
-	{0x0000a5bc, 0x4986222d, 0x4986222d, 0x38801640, 0x38801640},
-	{0x0000a5c0, 0x4d862231, 0x4d862231, 0x3c801660, 0x3c801660},
-	{0x0000a5c4, 0x50882231, 0x50882231, 0x3f801861, 0x3f801861},
-	{0x0000a5c8, 0x5688422e, 0x5688422e, 0x43801a81, 0x43801a81},
-	{0x0000a5cc, 0x5a88442e, 0x5a88442e, 0x47801a83, 0x47801a83},
-	{0x0000a5d0, 0x5e8a4431, 0x5e8a4431, 0x4a801c84, 0x4a801c84},
-	{0x0000a5d4, 0x648a4432, 0x648a4432, 0x4e801ce3, 0x4e801ce3},
-	{0x0000a5d8, 0x688a4434, 0x688a4434, 0x52801ce5, 0x52801ce5},
-	{0x0000a5dc, 0x6c8a6434, 0x6c8a6434, 0x56801ce9, 0x56801ce9},
-	{0x0000a5e0, 0x6f8a6633, 0x6f8a6633, 0x5a801ceb, 0x5a801ceb},
-	{0x0000a5e4, 0x738c6634, 0x738c6634, 0x5d801eec, 0x5d801eec},
-	{0x0000a5e8, 0x738c6634, 0x738c6634, 0x5d801eec, 0x5d801eec},
-	{0x0000a5ec, 0x738c6634, 0x738c6634, 0x5d801eec, 0x5d801eec},
-	{0x0000a5f0, 0x738c6634, 0x738c6634, 0x5d801eec, 0x5d801eec},
-	{0x0000a5f4, 0x738c6634, 0x738c6634, 0x5d801eec, 0x5d801eec},
-	{0x0000a5f8, 0x738c6634, 0x738c6634, 0x5d801eec, 0x5d801eec},
-	{0x0000a5fc, 0x738c6634, 0x738c6634, 0x5d801eec, 0x5d801eec},
+	{0x0000a590, 0x16800220, 0x16800220, 0x0f800202, 0x0f800202},
+	{0x0000a594, 0x1c800223, 0x1c800223, 0x12800400, 0x12800400},
+	{0x0000a598, 0x21802220, 0x21802220, 0x16800402, 0x16800402},
+	{0x0000a59c, 0x27802223, 0x27802223, 0x19800404, 0x19800404},
+	{0x0000a5a0, 0x2b822220, 0x2b822220, 0x1c800603, 0x1c800603},
+	{0x0000a5a4, 0x2f822222, 0x2f822222, 0x21800a02, 0x21800a02},
+	{0x0000a5a8, 0x34822225, 0x34822225, 0x25800a04, 0x25800a04},
+	{0x0000a5ac, 0x3a82222a, 0x3a82222a, 0x28800a20, 0x28800a20},
+	{0x0000a5b0, 0x3e82222c, 0x3e82222c, 0x2c800e20, 0x2c800e20},
+	{0x0000a5b4, 0x4282242a, 0x4282242a, 0x30800e22, 0x30800e22},
+	{0x0000a5b8, 0x4782244a, 0x4782244a, 0x34800e24, 0x34800e24},
+	{0x0000a5bc, 0x4b82244c, 0x4b82244c, 0x38801640, 0x38801640},
+	{0x0000a5c0, 0x4e82246c, 0x4e82246c, 0x3c801660, 0x3c801660},
+	{0x0000a5c4, 0x52822470, 0x52822470, 0x3f801861, 0x3f801861},
+	{0x0000a5c8, 0x55822490, 0x55822490, 0x43801a81, 0x43801a81},
+	{0x0000a5cc, 0x59822492, 0x59822492, 0x47801a83, 0x47801a83},
+	{0x0000a5d0, 0x5d822692, 0x5d822692, 0x4a801c84, 0x4a801c84},
+	{0x0000a5d4, 0x61822892, 0x61822892, 0x4e801ce3, 0x4e801ce3},
+	{0x0000a5d8, 0x65824890, 0x65824890, 0x52801ce5, 0x52801ce5},
+	{0x0000a5dc, 0x69824892, 0x69824892, 0x56801ce9, 0x56801ce9},
+	{0x0000a5e0, 0x6e824c92, 0x6e824c92, 0x5a801ceb, 0x5a801ceb},
+	{0x0000a5e4, 0x74826e92, 0x74826e92, 0x5d801eec, 0x5d801eec},
+	{0x0000a5e8, 0x74826e92, 0x74826e92, 0x5d801eec, 0x5d801eec},
+	{0x0000a5ec, 0x74826e92, 0x74826e92, 0x5d801eec, 0x5d801eec},
+	{0x0000a5f0, 0x74826e92, 0x74826e92, 0x5d801eec, 0x5d801eec},
+	{0x0000a5f4, 0x74826e92, 0x74826e92, 0x5d801eec, 0x5d801eec},
+	{0x0000a5f8, 0x74826e92, 0x74826e92, 0x5d801eec, 0x5d801eec},
+	{0x0000a5fc, 0x74826e92, 0x74826e92, 0x5d801eec, 0x5d801eec},
 	{0x0000a600, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a604, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
-	{0x0000a608, 0x01804601, 0x01804601, 0x00000000, 0x00000000},
-	{0x0000a60c, 0x01804601, 0x01804601, 0x00000000, 0x00000000},
-	{0x0000a610, 0x01804601, 0x01804601, 0x00000000, 0x00000000},
-	{0x0000a614, 0x01804601, 0x01804601, 0x01404000, 0x01404000},
-	{0x0000a618, 0x01804601, 0x01804601, 0x01404501, 0x01404501},
-	{0x0000a61c, 0x01804601, 0x01804601, 0x02008501, 0x02008501},
-	{0x0000a620, 0x03408d02, 0x03408d02, 0x0280ca03, 0x0280ca03},
-	{0x0000a624, 0x0300cc03, 0x0300cc03, 0x03010c04, 0x03010c04},
-	{0x0000a628, 0x03410d04, 0x03410d04, 0x04014c04, 0x04014c04},
-	{0x0000a62c, 0x03410d04, 0x03410d04, 0x04015005, 0x04015005},
-	{0x0000a630, 0x03410d04, 0x03410d04, 0x04015005, 0x04015005},
-	{0x0000a634, 0x03410d04, 0x03410d04, 0x04015005, 0x04015005},
-	{0x0000a638, 0x03410d04, 0x03410d04, 0x04015005, 0x04015005},
-	{0x0000a63c, 0x03410d04, 0x03410d04, 0x04015005, 0x04015005},
-	{0x0000b2dc, 0x000cfff0, 0x000cfff0, 0x03aaa352, 0x03aaa352},
-	{0x0000b2e0, 0x000f0000, 0x000f0000, 0x03ccc584, 0x03ccc584},
-	{0x0000b2e4, 0x03f00000, 0x03f00000, 0x03f0f800, 0x03f0f800},
+	{0x0000a608, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a60c, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a610, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a614, 0x02004000, 0x02004000, 0x01404000, 0x01404000},
+	{0x0000a618, 0x02004801, 0x02004801, 0x01404501, 0x01404501},
+	{0x0000a61c, 0x02808a02, 0x02808a02, 0x02008501, 0x02008501},
+	{0x0000a620, 0x0380ce03, 0x0380ce03, 0x0280ca03, 0x0280ca03},
+	{0x0000a624, 0x04411104, 0x04411104, 0x03010c04, 0x03010c04},
+	{0x0000a628, 0x04411104, 0x04411104, 0x04014c04, 0x04014c04},
+	{0x0000a62c, 0x04411104, 0x04411104, 0x04015005, 0x04015005},
+	{0x0000a630, 0x04411104, 0x04411104, 0x04015005, 0x04015005},
+	{0x0000a634, 0x04411104, 0x04411104, 0x04015005, 0x04015005},
+	{0x0000a638, 0x04411104, 0x04411104, 0x04015005, 0x04015005},
+	{0x0000a63c, 0x04411104, 0x04411104, 0x04015005, 0x04015005},
+	{0x0000b2dc, 0x00033800, 0x00033800, 0x03aaa352, 0x03aaa352},
+	{0x0000b2e0, 0x0003c000, 0x0003c000, 0x03ccc584, 0x03ccc584},
+	{0x0000b2e4, 0x03fc0000, 0x03fc0000, 0x03f0f800, 0x03f0f800},
 	{0x0000b2e8, 0x00000000, 0x00000000, 0x03ff0000, 0x03ff0000},
-	{0x0000c2dc, 0x000cfff0, 0x000cfff0, 0x03aaa352, 0x03aaa352},
-	{0x0000c2e0, 0x000f0000, 0x000f0000, 0x03ccc584, 0x03ccc584},
-	{0x0000c2e4, 0x03f00000, 0x03f00000, 0x03f0f800, 0x03f0f800},
+	{0x0000c2dc, 0x00033800, 0x00033800, 0x03aaa352, 0x03aaa352},
+	{0x0000c2e0, 0x0003c000, 0x0003c000, 0x03ccc584, 0x03ccc584},
+	{0x0000c2e4, 0x03fc0000, 0x03fc0000, 0x03f0f800, 0x03f0f800},
 	{0x0000c2e8, 0x00000000, 0x00000000, 0x03ff0000, 0x03ff0000},
 	{0x00016044, 0x012492d4, 0x012492d4, 0x012492d4, 0x012492d4},
-	{0x00016048, 0x61200001, 0x61200001, 0x66480001, 0x66480001},
+	{0x00016048, 0x66480001, 0x66480001, 0x66480001, 0x66480001},
 	{0x00016068, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c},
 	{0x00016444, 0x012492d4, 0x012492d4, 0x012492d4, 0x012492d4},
-	{0x00016448, 0x61200001, 0x61200001, 0x66480001, 0x66480001},
+	{0x00016448, 0x66480001, 0x66480001, 0x66480001, 0x66480001},
 	{0x00016468, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c},
 	{0x00016844, 0x012492d4, 0x012492d4, 0x012492d4, 0x012492d4},
-	{0x00016848, 0x61200001, 0x61200001, 0x66480001, 0x66480001},
+	{0x00016848, 0x66480001, 0x66480001, 0x66480001, 0x66480001},
 	{0x00016868, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c},
 };
=20
diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireles=
s/ath/ath9k/hif_usb.c
index 924c461..f5dda84 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -38,6 +38,7 @@ static struct usb_device_id ath9k_hif_usb_ids[] =3D {
 	{ USB_DEVICE(0x04CA, 0x4605) }, /* Liteon */
 	{ USB_DEVICE(0x040D, 0x3801) }, /* VIA */
 	{ USB_DEVICE(0x0cf3, 0xb003) }, /* Ubiquiti WifiStation Ext */
+	{ USB_DEVICE(0x0cf3, 0xb002) }, /* Ubiquiti WifiStation */
 	{ USB_DEVICE(0x057c, 0x8403) }, /* AVM FRITZ!WLAN 11N v2 USB */
=20
 	{ USB_DEVICE(0x0cf3, 0x7015),
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/mai=
n.c
index 73730e9..c5a99c8 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -5404,6 +5404,8 @@ static void b43_bcma_remove(struct bcma_device *core)
 	cancel_work_sync(&wldev->restart_work);
=20
 	B43_WARN_ON(!wl);
+	if (!wldev->fw.ucode.data)
+		return;			/* NULL if firmware never loaded */
 	if (wl->current_dev =3D=3D wldev && wl->hw_registred) {
 		b43_leds_stop(wldev);
 		ieee80211_unregister_hw(wl->hw);
@@ -5478,6 +5480,8 @@ static void b43_ssb_remove(struct ssb_device *sdev)
 	cancel_work_sync(&wldev->restart_work);
=20
 	B43_WARN_ON(!wl);
+	if (!wldev->fw.ucode.data)
+		return;			/* NULL if firmware never loaded */
 	if (wl->current_dev =3D=3D wldev && wl->hw_registred) {
 		b43_leds_stop(wldev);
 		ieee80211_unregister_hw(wl->hw);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 411dfe7..a6f1e81 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -3569,7 +3569,7 @@ brcmf_cfg80211_sched_scan_start(struct wiphy *wiphy,
=20
 	if (!request || !request->n_ssids || !request->n_match_sets) {
 		WL_ERR("Invalid sched scan req!! n_ssids:%d\n",
-		       request->n_ssids);
+		       request ? request->n_ssids : 0);
 		return -EINVAL;
 	}
=20
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index 0679458..780d3e1 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1825,8 +1825,6 @@ mwifiex_cfg80211_scan(struct wiphy *wiphy,
 		return -EBUSY;
 	}
=20
-	priv->scan_request =3D request;
-
 	priv->user_scan_cfg =3D kzalloc(sizeof(struct mwifiex_user_scan_cfg),
 				      GFP_KERNEL);
 	if (!priv->user_scan_cfg) {
@@ -1834,6 +1832,8 @@ mwifiex_cfg80211_scan(struct wiphy *wiphy,
 		return -ENOMEM;
 	}
=20
+	priv->scan_request =3D request;
+
 	priv->user_scan_cfg->num_ssids =3D request->n_ssids;
 	priv->user_scan_cfg->ssid_list =3D request->ssids;
=20
@@ -1870,6 +1870,9 @@ mwifiex_cfg80211_scan(struct wiphy *wiphy,
 	ret =3D mwifiex_scan_networks(priv, priv->user_scan_cfg);
 	if (ret) {
 		dev_err(priv->adapter->dev, "scan failed: %d\n", ret);
+		priv->scan_request =3D NULL;
+		kfree(priv->user_scan_cfg);
+		priv->user_scan_cfg =3D NULL;
 		return ret;
 	}
=20
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwi=
fiex/scan.c
index 00b658d..9171aae 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -1843,21 +1843,18 @@ static int mwifiex_scan_specific_ssid(struct mwifie=
x_private *priv,
 				      struct cfg80211_ssid *req_ssid)
 {
 	struct mwifiex_adapter *adapter =3D priv->adapter;
-	int ret =3D 0;
+	int ret;
 	struct mwifiex_user_scan_cfg *scan_cfg;
=20
-	if (!req_ssid)
-		return -1;
-
 	if (adapter->scan_processing) {
-		dev_dbg(adapter->dev, "cmd: Scan already in process...\n");
-		return ret;
+		dev_err(adapter->dev, "cmd: Scan already in process...\n");
+		return -EBUSY;
 	}
=20
 	if (priv->scan_block) {
-		dev_dbg(adapter->dev,
+		dev_err(adapter->dev,
 			"cmd: Scan is blocked during association...\n");
-		return ret;
+		return -EBUSY;
 	}
=20
 	scan_cfg =3D kzalloc(sizeof(struct mwifiex_user_scan_cfg), GFP_KERNEL);
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless=
/rt2x00/rt2500usb.c
index a12e84f..6b2e1e43 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -1988,6 +1988,7 @@ static struct usb_driver rt2500usb_driver =3D {
 	.disconnect	=3D rt2x00usb_disconnect,
 	.suspend	=3D rt2x00usb_suspend,
 	.resume		=3D rt2x00usb_resume,
+	.reset_resume	=3D rt2x00usb_resume,
 	.disable_hub_initiated_lpm =3D 1,
 };
=20
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless=
/rt2x00/rt2800usb.c
index c9e9370..3b8fb5a 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -1282,6 +1282,7 @@ static struct usb_driver rt2800usb_driver =3D {
 	.disconnect	=3D rt2x00usb_disconnect,
 	.suspend	=3D rt2x00usb_suspend,
 	.resume		=3D rt2x00usb_resume,
+	.reset_resume	=3D rt2x00usb_resume,
 	.disable_hub_initiated_lpm =3D 1,
 };
=20
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/r=
t2x00/rt73usb.c
index e5eb43b..24eec66 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2535,6 +2535,7 @@ static struct usb_driver rt73usb_driver =3D {
 	.disconnect	=3D rt2x00usb_disconnect,
 	.suspend	=3D rt2x00usb_suspend,
 	.resume		=3D rt2x00usb_resume,
+	.reset_resume	=3D rt2x00usb_resume,
 	.disable_hub_initiated_lpm =3D 1,
 };
=20
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index 030beb4..e3ea4b3 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -673,7 +673,7 @@ static int rtl_usb_start(struct ieee80211_hw *hw)
 		set_hal_start(rtlhal);
=20
 		/* Start bulk IN */
-		_rtl_usb_receive(hw);
+		err =3D _rtl_usb_receive(hw);
 	}
=20
 	return err;
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--/04w6evG8XlLl3ft
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQiqpoAAoJEJctW/TcYTgGQwcP/A6MV3vZBfTkOB5nP68HwdUC
LnNTf+biEvXKC+RR3aei8awVoriNY7RUAy2HwTI9qxwq6wrJ+ZN4LF3vh7uSrJOX
k746TaxTtC8L+TniIUTi/q+kfm6UsPXXjtBJEddNs9oLPOkl5kDe7NWK0ytPCvVf
xLBmTxOGyHcOA7Rith9HbH8KLxezr3621hmU0hzqitPwpgpyZjDFiXGgZuYG0h8n
GGXVrJCayS90hf5SFsNQkJo43n6xrbb1kocPoQbo1VhmIjGCNjICwsQKe/BtGSsU
IA0ADxjix8du/R54uekzbNAaxky8EmJ7xvPf4s0c8cvkkRuz8KN7Nle6KHsP2a44
qE6D3IAo6A0Ak/yHZPn8F3DLHR3se40L3keEC/EJ1Uhazj6terXu6w6v8RrawsAh
ohthSZvQJ2vu2/bI+hB9IK1FDTRfql5drN2nVZejuidITL4hIVJ8waIWzcVLYuKN
OfF9eCxHlK4bZLP2t5pWIEnHR3umOB9DNNfGYA3U4qKeR66DcbzaZ/q982kSxVEd
qgH3/SdMOCugzqIex/rBiRjSrCxEYeYYH29orQZ1UlScn42ohMjzR3YjtsncoNHa
szjMXv7ViECBaCHGuIjO2bUVIzyj0U1gR3S3luaf/GHrqJLwAP5xynmbhDIZkp8y
dvClF4G/U1iRl/f0Shju
=7SVM
-----END PGP SIGNATURE-----

--/04w6evG8XlLl3ft--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
