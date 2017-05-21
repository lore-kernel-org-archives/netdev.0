From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: brcmfmac firmware issue on NanoPi K2
Date: Sun, 21 May 2017 18:20:25 +0200
Message-ID: <ab713116-ab12-5f87-1ecf-cae2e0d68b93@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        technicalsupport <techsupport@friendlyarm.com>,
        Arend Van Spriel <arend.vanspriel@broadcom.com>,
        linux-amlogic <linux-amlogic@lists.infradead.org>
To: linux-wireless@vger.kernel.org, brcm80211-dev-list.pdl@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53287 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751583AbdEUQU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 12:20:27 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The NanoPi K2 has an Ampak AP6212 SDIO module. brcmfmac driver loads
brcmfmac43430-sdio.bin.

When using the firmware file from linux-firmware.git that openSUSE ships
I get the following errors on 4.11.0 and next-20170519:

[ 2103.618716] brcmfmac: brcmf_sdio_htclk: HT Avail timeout (1000000):
clkctl 0x50
[ 2104.668746] brcmfmac: brcmf_sdio_htclk: HT Avail timeout (1000000):
clkctl 0x50
[ 2105.678677] brcmfmac: brcmf_sdio_htclk: HT Avail timeout (1000000):
clkctl 0x50

If I overwrite /lib/firmware/brcm/bcm43430-sdio.bin with
fw_bcm43438a0.bin from FriendlyARM's Android repository it suddenly works:

[  +0.157738] brcmfmac: brcmf_c_preinit_dcmds: Firmware version = wl0:
Jun  6 2014 14:50:39 version 7.10.226.49 (r) FWID 01-8962686a
[  +0.160108] brcmfmac: brcmf_cfg80211_reg_notifier: not a ISO3166 code
(0x30 0x30)

I recall using the linux-firmware.git brcmfmac43430-sdio.bin file
successfully on the Raspberry Pi 3 with a downstream (Leap 42.2) kernel.

I've tested both nvram_ap6212.txt and nvram_ap6212a.txt, the latter has
the following diff to nvram.txt:

--- nvram_ap6212.txt    2017-05-21 04:24:40.372113426 +0200
+++ nvram_ap6212a.txt   2017-05-21 04:24:49.852116599 +0200
@@ -1,4 +1,4 @@
-#AP6212_NVRAM_V1.0_20140603
+#AP6212_NVRAM_V1.0.1_20160606
 # 2.4 GHz, 20 MHz BW mode

 # The following parameter values are just placeholders, need to be updated.
@@ -51,4 +51,4 @@
 muxenab=0x10
 # CLDO PWM voltage settings - 0x4 - 1.1 volt
 #cldo_pwm=0x4
-
+glitch_based_crsmin=1

https://github.com/friendlyarm/android_hardware_amlogic_wifi/tree/l-amlogic-gx-sync/bcm_ampak/config/6212

* Does the linux-firmware.git brcmfmac43430-sdio.bin need a fix for AP6212?
https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/brcm

* Does the brcmfmac driver need to distinguish revisions in sdio.c as
done for 43241, plus a separate firmware file?
	BRCMF_FW_NVRAM_ENTRY(BRCM_CC_43430_CHIP_ID, 0xFFFFFFFF, 43430),

* Any other ideas?

Thanks,
Andreas

-- 
SUSE Linux GmbH, Maxfeldstr. 5, 90409 Nürnberg, Germany
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
