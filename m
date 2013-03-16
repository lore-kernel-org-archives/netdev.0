From: Parag Warudkar <parag.lkml@gmail.com>
Subject: [PATCH] ath9k : Fix ieee80211 work while going to suspend
Date: Sat, 16 Mar 2013 12:38:14 -0400
Message-ID: <CAOULuOb0_40EX+6A_HM8eJN7kj9J4WhO9UhZbUUqng1Sfy_SQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7ba97b72d4a75d04d80d6139
To: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	senthilb@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:62820 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755625Ab3CPQiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 12:38:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--047d7ba97b72d4a75d04d80d6139
Content-Type: text/plain; charset=ISO-8859-1

During suspend below warning is seen when ath9k is active.  Attached
patch fixes the warning for me. Tested to work across few
suspend-resume cycles.


Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642939] WARNING: at
net/mac80211/util.c:599 ieee80211_can_queue_work.isra.7+0x32/0x40
[mac80211]()
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642940] Hardware name: iMac12,1
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642941] queueing ieee80211
work while going to suspend
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642972] Modules linked in:
joydev hid_logitech_dj zfs(POF) bridge stp llc zunicode(POF) zavl(POF)
zcommon(POF) znvpair(POF) spl(OF) zlib_deflate be2iscsi
iscsi_boot_sysfs bnx2i cnic uio cxgb4i cxgb4 cxgb3i cxgb3 mdio
libcxgbi ib_iser rdma_cm ib_addr iw_cm ib_cm ib_sa ib_mad ib_core
iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi rfcomm bnep
nls_utf8 hfsplus btusb uvcvideo videobuf2_vmalloc videobuf2_memops
videobuf2_core videodev bluetooth media coretemp snd_hda_codec_hdmi
snd_hda_codec_cirrus snd_hda_intel snd_hda_codec snd_hwdep snd_seq
snd_seq_device snd_pcm snd_page_alloc snd_timer snd soundcore arc4
ath9k ath9k_common microcode ath9k_hw ath mac80211 iTCO_wdt
iTCO_vendor_support cfg80211 lpc_ich mei mfd_core rfkill i2c_i801
applesmc apple_bl input_polldev vhost_net tun macvtap macvlan
kvm_intel kvm binfmt_misc uinput usb_storage crc32c_intel radeon ttm
i915 ghash_clmulni_intel firewire_ohci firewire_core i2c_algo_bit
drm_kms_helper crc_itu_t drm tg3 ptp pps_core i2c_core video sunrpc
[last unloaded: iptable_mangle]
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642985] Pid: 0, comm:
swapper/0 Tainted: PF          O 3.8.2-206.fc18.x86_64 #1
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642986] Call Trace:
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.642992]  <IRQ>
[<ffffffff8105e61f>] warn_slowpath_common+0x7f/0xc0
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643009]
[<ffffffffa0581420>] ? ath_start_rx_poll+0x70/0x70 [ath9k]
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643011]
[<ffffffff8105e716>] warn_slowpath_fmt+0x46/0x50
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643018]
[<ffffffffa045b542>] ieee80211_can_queue_work.isra.7+0x32/0x40
[mac80211]
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643024]
[<ffffffffa045b5de>] ieee80211_queue_work+0x2e/0x50 [mac80211]
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643027]
[<ffffffffa0581438>] ath_rx_poll+0x18/0x20 [ath9k]
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643029]
[<ffffffff8106d0aa>] call_timer_fn+0x3a/0x120
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643032]
[<ffffffffa0581420>] ? ath_start_rx_poll+0x70/0x70 [ath9k]
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643034]
[<ffffffff814fb240>] ? cpufreq_p4_target+0x120/0x120
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643035]
[<ffffffff8106ee3e>] run_timer_softirq+0x1fe/0x2b0
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643037]
[<ffffffff814fb240>] ? cpufreq_p4_target+0x120/0x120
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643038]
[<ffffffff81066cd0>] __do_softirq+0xd0/0x210
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643040]
[<ffffffff8101b913>] ? native_sched_clock+0x13/0x80
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643041]
[<ffffffff814fb240>] ? cpufreq_p4_target+0x120/0x120
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643043]
[<ffffffff8165985c>] call_softirq+0x1c/0x30
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643045]
[<ffffffff810162a5>] do_softirq+0x75/0xb0
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643046]
[<ffffffff81066fa5>] irq_exit+0xb5/0xc0
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643048]
[<ffffffff8165a1de>] smp_apic_timer_interrupt+0x6e/0x99
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643049]
[<ffffffff8165911d>] apic_timer_interrupt+0x6d/0x80
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643052]  <EOI>
[<ffffffff810868ce>] ? __hrtimer_start_range_ns+0x1be/0x400
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643053]
[<ffffffff814fbc30>] ? cpuidle_wrap_enter+0x50/0xa0
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643054]
[<ffffffff814fbc29>] ? cpuidle_wrap_enter+0x49/0xa0
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643056]
[<ffffffff814fbc90>] cpuidle_enter_tk+0x10/0x20
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643057]
[<ffffffff814fb8c9>] cpuidle_idle_call+0xa9/0x260
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643058]
[<ffffffff8101d45f>] cpu_idle+0xaf/0x120
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643061]
[<ffffffff81634522>] rest_init+0x72/0x80
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643063]
[<ffffffff81d00c40>] start_kernel+0x3d1/0x3de
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643065]
[<ffffffff81d0066e>] ? repair_env_string+0x5e/0x5e
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643066]
[<ffffffff81d00356>] x86_64_start_reservations+0x131/0x135
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643068]
[<ffffffff81d0045a>] x86_64_start_kernel+0x100/0x10f
Mar 16 09:39:17 Parags-iMac kernel: [ 3993.643068] ---[ end trace
5595a7f5dd9a2949 ]---

Signed-off-by: Parag Warudkar <parag.lkml@gmail.com>

diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h
b/drivers/net/wireless/ath/ath9k/ath9k.h
index a56b241..b3088a1 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -764,6 +764,7 @@ struct ath_softc {
  atomic_t wow_got_bmiss_intr;
  atomic_t wow_sleep_proc_intr; /* in the middle of WoW sleep ? */
  u32 wow_intr_before_sleep;
+ bool suspending;
 #endif
 };

diff --git a/drivers/net/wireless/ath/ath9k/link.c
b/drivers/net/wireless/ath/ath9k/link.c
index ade3afb..fa77e19 100644
--- a/drivers/net/wireless/ath/ath9k/link.c
+++ b/drivers/net/wireless/ath/ath9k/link.c
@@ -158,7 +158,8 @@ void ath_start_rx_poll(struct ath_softc *sc, u8 nbeacon)
 {
  if (!AR_SREV_9300(sc->sc_ah))
  return;
-
+ if (sc->suspending)
+ return;
  if (!test_bit(SC_OP_PRIM_STA_VIF, &sc->sc_flags))
  return;

diff --git a/drivers/net/wireless/ath/ath9k/main.c
b/drivers/net/wireless/ath/ath9k/main.c
index 6e66f9c..0cf88b7 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -2150,7 +2150,7 @@ static int ath9k_suspend(struct ieee80211_hw *hw,
  int ret = 0;

  mutex_lock(&sc->mutex);
-
+ sc->suspending = 1;
  ath_cancel_work(sc);
  ath_stop_ani(sc);
  del_timer_sync(&sc->rx_poll_timer);
@@ -2288,6 +2288,7 @@ static int ath9k_resume(struct ieee80211_hw *hw)
  ath9k_start_btcoex(sc);

  ath9k_ps_restore(sc);
+ sc->suspending = 0;
  mutex_unlock(&sc->mutex);

  return 0;

--047d7ba97b72d4a75d04d80d6139
Content-Type: application/octet-stream; name="ath9k.patch"
Content-Disposition: attachment; filename="ath9k.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_heczxl2u0

U2lnbmVkLW9mZi1ieTogUGFyYWcgV2FydWRrYXIgPHBhcmFnLmxrbWxAZ21haWwuY29tPgoKZGlm
ZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2F0aC9hdGg5ay9hdGg5ay5oIGIvZHJpdmVy
cy9uZXQvd2lyZWxlc3MvYXRoL2F0aDlrL2F0aDlrLmgKaW5kZXggYTU2YjI0MS4uYjMwODhhMSAx
MDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvd2lyZWxlc3MvYXRoL2F0aDlrL2F0aDlrLmgKKysrIGIv
ZHJpdmVycy9uZXQvd2lyZWxlc3MvYXRoL2F0aDlrL2F0aDlrLmgKQEAgLTc2NCw2ICs3NjQsNyBA
QCBzdHJ1Y3QgYXRoX3NvZnRjIHsKIAlhdG9taWNfdCB3b3dfZ290X2JtaXNzX2ludHI7CiAJYXRv
bWljX3Qgd293X3NsZWVwX3Byb2NfaW50cjsgLyogaW4gdGhlIG1pZGRsZSBvZiBXb1cgc2xlZXAg
PyAqLwogCXUzMiB3b3dfaW50cl9iZWZvcmVfc2xlZXA7CisJYm9vbCBzdXNwZW5kaW5nOwogI2Vu
ZGlmCiB9OwogCmRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC93aXJlbGVzcy9hdGgvYXRoOWsvbGlu
ay5jIGIvZHJpdmVycy9uZXQvd2lyZWxlc3MvYXRoL2F0aDlrL2xpbmsuYwppbmRleCBhZGUzYWZi
Li5mYTc3ZTE5IDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC93aXJlbGVzcy9hdGgvYXRoOWsvbGlu
ay5jCisrKyBiL2RyaXZlcnMvbmV0L3dpcmVsZXNzL2F0aC9hdGg5ay9saW5rLmMKQEAgLTE1OCw3
ICsxNTgsOCBAQCB2b2lkIGF0aF9zdGFydF9yeF9wb2xsKHN0cnVjdCBhdGhfc29mdGMgKnNjLCB1
OCBuYmVhY29uKQogewogCWlmICghQVJfU1JFVl85MzAwKHNjLT5zY19haCkpCiAJCXJldHVybjsK
LQorCWlmIChzYy0+c3VzcGVuZGluZykKKwkJcmV0dXJuOwogCWlmICghdGVzdF9iaXQoU0NfT1Bf
UFJJTV9TVEFfVklGLCAmc2MtPnNjX2ZsYWdzKSkKIAkJcmV0dXJuOwogCmRpZmYgLS1naXQgYS9k
cml2ZXJzL25ldC93aXJlbGVzcy9hdGgvYXRoOWsvbWFpbi5jIGIvZHJpdmVycy9uZXQvd2lyZWxl
c3MvYXRoL2F0aDlrL21haW4uYwppbmRleCA2ZTY2ZjljLi4wY2Y4OGI3IDEwMDY0NAotLS0gYS9k
cml2ZXJzL25ldC93aXJlbGVzcy9hdGgvYXRoOWsvbWFpbi5jCisrKyBiL2RyaXZlcnMvbmV0L3dp
cmVsZXNzL2F0aC9hdGg5ay9tYWluLmMKQEAgLTIxNTAsNyArMjE1MCw3IEBAIHN0YXRpYyBpbnQg
YXRoOWtfc3VzcGVuZChzdHJ1Y3QgaWVlZTgwMjExX2h3ICpodywKIAlpbnQgcmV0ID0gMDsKIAog
CW11dGV4X2xvY2soJnNjLT5tdXRleCk7Ci0KKwlzYy0+c3VzcGVuZGluZyA9IDE7CiAJYXRoX2Nh
bmNlbF93b3JrKHNjKTsKIAlhdGhfc3RvcF9hbmkoc2MpOwogCWRlbF90aW1lcl9zeW5jKCZzYy0+
cnhfcG9sbF90aW1lcik7CkBAIC0yMjg4LDYgKzIyODgsNyBAQCBzdGF0aWMgaW50IGF0aDlrX3Jl
c3VtZShzdHJ1Y3QgaWVlZTgwMjExX2h3ICpodykKIAlhdGg5a19zdGFydF9idGNvZXgoc2MpOwog
CiAJYXRoOWtfcHNfcmVzdG9yZShzYyk7CisJc2MtPnN1c3BlbmRpbmcgPSAwOwogCW11dGV4X3Vu
bG9jaygmc2MtPm11dGV4KTsKIAogCXJldHVybiAwOwo=
--047d7ba97b72d4a75d04d80d6139--
