From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: qmi_wwan: Null pointer dereference when removing driver
Date: Tue, 08 Aug 2017 12:35:06 +0200
Message-ID: <87d1861h5x.fsf@miraculix.mork.no>
References: <0d39998a-dfa9-48c5-0c7f-19354f16a7c0@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: netdev@vger.kernel.org, Daniele Palmas <dnlplm@gmail.com>
To: Nathaniel Roach <nroach44@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35001 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751921AbdHHKfY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 06:35:24 -0400
In-Reply-To: <0d39998a-dfa9-48c5-0c7f-19354f16a7c0@gmail.com> (Nathaniel
        Roach's message of "Thu, 27 Jul 2017 13:31:00 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Nathaniel Roach <nroach44@gmail.com> writes:

> Unsure at which point was added, but issue not present in stock debian 4.=
11 kernel.
>
> Running on a Thinkpad X220 with coreboot.
>
> I'm building from upstream. When I attempt to remove the qmi_wwan module =
(which also happens pre-suspend) the rmmod process gets killed, and the fol=
lowing shows in dmesg:
>
> [   59.979791] usb 2-1.4: USB disconnect, device number 4
> [   59.980102] qmi_wwan 2-1.4:1.6 wwp0s29u1u4i6: unregister 'qmi_wwan' us=
b-0000:00:1d.0-1.4, WWAN/QMI device
> [   60.006821] BUG: unable to handle kernel NULL pointer dereference at 0=
0000000000000e0
> [   60.006879] IP: qmi_wwan_disconnect+0x25/0xc0 [qmi_wwan]
> [   60.006911] PGD 0
> [   60.006911] P4D 0
> [   60.006957] Oops: 0000 [#1] SMP
> [   60.006978] Modules linked in: fuse(E) ccm(E) rfcomm(E) cmac(E) bnep(E=
) qmi_wwan(E) cdc_wdm(E) cdc_ether(E) usbnet(E) mii(E) btusb(E) btrtl(E) bt=
bcm(E) btintel(E) bluetooth(E) joydev(E) xpad(E) ecdh_generic(E) ff_memless=
(E) binfmt_misc(E) snd_hda_codec_hdmi(E) snd_hda_codec_conexant(E) snd_hda_=
codec_generic(E) arc4(E) iTCO_wdt(E) iTCO_vendor_support(E) intel_rapl(E) x=
86_pkg_temp_thermal(E) kvm_intel(E) kvm(E) irqbypass(E) crct10dif_pclmul(E)=
 crc32_pclmul(E) crc32c_intel(E) ghash_clmulni_intel(E) aesni_intel(E) iwlm=
vm(E) aes_x86_64(E) crypto_simd(E) mac80211(E) cryptd(E) glue_helper(E) snd=
_hda_intel(E) snd_hda_codec(E) iwlwifi(E) snd_hwdep(E) psmouse(E) snd_hda_c=
ore(E) snd_pcm(E) serio_raw(E) sdhci_pci(E) pcspkr(E) snd_timer(E) ehci_pci=
(E) e1000e(E) i2c_i801(E) ehci_hcd(E) snd(E) sg(E) i915(E) lpc_ich(E)
> [   60.007366]  ptp(E) usbcore(E) cfg80211(E) mfd_core(E) pps_core(E) shp=
chp(E) ac(E) battery(E) tpm_tis(E) tpm_tis_core(E) evdev(E) tpm(E) parport_=
pc(E) ppdev(E) lp(E) parport(E) ip_tables(E) x_tables(E) autofs4(E)
> [   60.007474] CPU: 2 PID: 33 Comm: kworker/2:1 Tainted: G            E  =
 4.12.3-nr44-normandy-r1500619820+ #1
> [   60.007524] Hardware name: LENOVO 4291LR7/4291LR7, BIOS CBET4000 4.6-8=
10-g50522254fb 07/21/2017
> [   60.007580] Workqueue: usb_hub_wq hub_event [usbcore]
> [   60.007609] task: ffff8c882b716040 task.stack: ffffb8e800d84000
> [   60.007644] RIP: 0010:qmi_wwan_disconnect+0x25/0xc0 [qmi_wwan]
> [   60.007678] RSP: 0018:ffffb8e800d87b38 EFLAGS: 00010246
> [   60.007711] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 000000000=
0000000
> [   60.007752] RDX: 0000000000000001 RSI: ffff8c8824f3f1d0 RDI: ffff8c882=
4ef6400
> [   60.007792] RBP: ffff8c8824ef6400 R08: 0000000000000000 R09: 000000000=
0000000
> [   60.007833] R10: ffffb8e800d87780 R11: 0000000000000011 R12: ffffffffc=
07ea0e8
> [   60.007874] R13: ffff8c8824e2e000 R14: ffff8c8824e2e098 R15: 000000000=
0000000
> [   60.007915] FS:  0000000000000000(0000) GS:ffff8c8835300000(0000) knlG=
S:0000000000000000
> [   60.007960] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   60.007994] CR2: 00000000000000e0 CR3: 0000000229ca5000 CR4: 000000000=
00406e0
> [   60.008035] Call Trace:
> [   60.008065]  ? usb_unbind_interface+0x71/0x270 [usbcore]
> [   60.008101]  ? device_release_driver_internal+0x154/0x210
> [   60.008135]  ? qmi_wwan_unbind+0x6d/0xc0 [qmi_wwan]
> [   60.008168]  ? usbnet_disconnect+0x6c/0xf0 [usbnet]
> [   60.008194]  ? qmi_wwan_disconnect+0x87/0xc0 [qmi_wwan]
> [   60.008232]  ? usb_unbind_interface+0x71/0x270 [usbcore]
> [   60.008264]  ? device_release_driver_internal+0x154/0x210
> [   60.008296]  ? bus_remove_device+0xf5/0x160
> [   60.008324]  ? device_del+0x1dc/0x310
> [   60.008355]  ? usb_remove_ep_devs+0x1b/0x30 [usbcore]
> [   60.008393]  ? usb_disable_device+0x93/0x250 [usbcore]
> [   60.008430]  ? usb_disconnect+0x90/0x260 [usbcore]
> [   60.008468]  ? hub_event+0x1d9/0x14a0 [usbcore]
> [   60.008500]  ? process_one_work+0x175/0x370
> [   60.008528]  ? worker_thread+0x4a/0x380
> [   60.008555]  ? kthread+0xfc/0x130
> [   60.008579]  ? process_one_work+0x370/0x370
> [   60.008606]  ? kthread_park+0x60/0x60
> [   60.008631]  ? ret_from_fork+0x22/0x30
> [   60.008656] Code: 66 0f 1f 44 00 00 66 66 66 66 90 55 48 89 fd 53 48 8=
3 ec 10 48 8b 9f c8 00 00 00 65 48 8b 04 25 28 00 00 00 48 89 44 24 08 31 c=
0 <f6> 83 e0 00 00 00 02 74 51 e8 0d b3 2b cd 85 c0 74 67 48 8b bb
> [   60.011925] RIP: qmi_wwan_disconnect+0x25/0xc0 [qmi_wwan] RSP: ffffb8e=
800d87b38
> [   60.013564] CR2: 00000000000000e0
> [   60.022125] ---[ end trace e536b59f45bc0f25 ]---
> [   60.025385] IPv6: ADDRCONF(NETDEV_UP): wlp2s0: link is not ready
>
> If I attempt a second rmmod, the process hangs. If I attempt it on 4.11.x=
 it works as expected:
>
> [   16.897783] fuse init (API version 7.26)
> [   68.073552] usbcore: deregistering interface driver qmi_wwan
> [   68.075808] qmi_wwan 2-1.4:1.6 wwp0s29u1u4i6: unregister 'qmi_wwan' us=
b-0000:00:1d.0-1.4, WWAN/QMI device
> [   72.431403] e1000e: enp0s25 NIC Link is Down
>
> So I'm pretty certain it's not coreboot causing the issue.


Thanks a lot for the report!  Just one question: Does your modem have
separate control and data interfaces? If so, then I believe the
attached patch will fix the issue.  Are you able to test it?

If the modem use the more common cobined interface model. then I need to
investigate this further..


Bj=C3=B8rn

--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: inline;
 filename=0001-qmi_wwan-fix-NULL-deref-on-disconnect.patch
Content-Transfer-Encoding: quoted-printable

>From c6ca53a5aaf6ce6a2733f75363119444adbe5d82 Mon Sep 17 00:00:00 2001
From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn@mork.no>
Date: Tue, 8 Aug 2017 12:17:25 +0200
Subject: [RFT] qmi_wwan: fix NULL deref on disconnect
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

qmi_wwan_disconnect is called twice when disconnecting devices with
separate control and data interfaces.  The first invocation will set
the interface data to NULL to flag that disconnect has been handled.
But the matching NULL check was left out when qmi_wwan_disconnect
was added, resulting in this oops:

  usb 2-1.4: USB disconnect, device number 4
  qmi_wwan 2-1.4:1.6 wwp0s29u1u4i6: unregister 'qmi_wwan' usb-0000:00:1d.0-=
1.4, WWAN/QMI device
  BUG: unable to handle kernel NULL pointer dereference at 00000000000000e0
  IP: qmi_wwan_disconnect+0x25/0xc0 [qmi_wwan]
  PGD 0
  P4D 0
  Oops: 0000 [#1] SMP
  Modules linked in: <stripped irrelevant module list>
  CPU: 2 PID: 33 Comm: kworker/2:1 Tainted: G            E   4.12.3-nr44-no=
rmandy-r1500619820+ #1
  Hardware name: LENOVO 4291LR7/4291LR7, BIOS CBET4000 4.6-810-g50522254fb =
07/21/2017
  Workqueue: usb_hub_wq hub_event [usbcore]
  task: ffff8c882b716040 task.stack: ffffb8e800d84000
  RIP: 0010:qmi_wwan_disconnect+0x25/0xc0 [qmi_wwan]
  RSP: 0018:ffffb8e800d87b38 EFLAGS: 00010246
  RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
  RDX: 0000000000000001 RSI: ffff8c8824f3f1d0 RDI: ffff8c8824ef6400
  RBP: ffff8c8824ef6400 R08: 0000000000000000 R09: 0000000000000000
  R10: ffffb8e800d87780 R11: 0000000000000011 R12: ffffffffc07ea0e8
  R13: ffff8c8824e2e000 R14: ffff8c8824e2e098 R15: 0000000000000000
  FS:  0000000000000000(0000) GS:ffff8c8835300000(0000) knlGS:0000000000000=
000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00000000000000e0 CR3: 0000000229ca5000 CR4: 00000000000406e0
  Call Trace:
   ? usb_unbind_interface+0x71/0x270 [usbcore]
   ? device_release_driver_internal+0x154/0x210
   ? qmi_wwan_unbind+0x6d/0xc0 [qmi_wwan]
   ? usbnet_disconnect+0x6c/0xf0 [usbnet]
   ? qmi_wwan_disconnect+0x87/0xc0 [qmi_wwan]
   ? usb_unbind_interface+0x71/0x270 [usbcore]
   ? device_release_driver_internal+0x154/0x210

Reported-by: Nathaniel Roach <nroach44@gmail.com>
Fixes: c6adf77953bc ("net: usb: qmi_wwan: add qmap mux protocol support")
Cc: Daniele Palmas <dnlplm@gmail.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index ff6f39fe6c00..8c3733608271 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -1341,10 +1341,14 @@ static int qmi_wwan_probe(struct usb_interface *int=
f,
 static void qmi_wwan_disconnect(struct usb_interface *intf)
 {
 	struct usbnet *dev =3D usb_get_intfdata(intf);
-	struct qmi_wwan_state *info =3D (void *)&dev->data;
+	struct qmi_wwan_state *info;
 	struct list_head *iter;
 	struct net_device *ldev;
=20
+	/* called twice if separate control and data intf */
+	if (!dev)
+		return;
+	info =3D (void *)&dev->data;
 	if (info->flags & QMI_WWAN_FLAG_MUX) {
 		if (!rtnl_trylock()) {
 			restart_syscall();
--=20
2.11.0


--=-=-=--
