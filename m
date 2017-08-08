From: Nathaniel Roach <nroach44@gmail.com>
Subject: Re: qmi_wwan: Null pointer dereference when removing driver
Date: Tue, 8 Aug 2017 22:18:02 +0800
Message-ID: <8aec9f1d-458e-ad09-e909-c0e83a1ed519@gmail.com>
References: <0d39998a-dfa9-48c5-0c7f-19354f16a7c0@gmail.com>
 <87d1861h5x.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Daniele Palmas <dnlplm@gmail.com>
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34079 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752014AbdHHOSI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 10:18:08 -0400
Received: by mail-pf0-f176.google.com with SMTP id o86so15180859pfj.1
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 07:18:08 -0700 (PDT)
In-Reply-To: <87d1861h5x.fsf@miraculix.mork.no>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yup, that patch works perfectly, and yes the device is a multi-tty device.

Cheers for everything!


On 08/08/17 18:35, Bjørn Mork wrote:
> Nathaniel Roach <nroach44@gmail.com> writes:
>
>> Unsure at which point was added, but issue not present in stock debian 4.11 kernel.
>>
>> Running on a Thinkpad X220 with coreboot.
>>
>> I'm building from upstream. When I attempt to remove the qmi_wwan module (which also happens pre-suspend) the rmmod process gets killed, and the following shows in dmesg:
>>
>> [   59.979791] usb 2-1.4: USB disconnect, device number 4
>> [   59.980102] qmi_wwan 2-1.4:1.6 wwp0s29u1u4i6: unregister 'qmi_wwan' usb-0000:00:1d.0-1.4, WWAN/QMI device
>> [   60.006821] BUG: unable to handle kernel NULL pointer dereference at 00000000000000e0
>> [   60.006879] IP: qmi_wwan_disconnect+0x25/0xc0 [qmi_wwan]
>> [   60.006911] PGD 0
>> [   60.006911] P4D 0
>> [   60.006957] Oops: 0000 [#1] SMP
>> [   60.006978] Modules linked in: fuse(E) ccm(E) rfcomm(E) cmac(E) bnep(E) qmi_wwan(E) cdc_wdm(E) cdc_ether(E) usbnet(E) mii(E) btusb(E) btrtl(E) btbcm(E) btintel(E) bluetooth(E) joydev(E) xpad(E) ecdh_generic(E) ff_memless(E) binfmt_misc(E) snd_hda_codec_hdmi(E) snd_hda_codec_conexant(E) snd_hda_codec_generic(E) arc4(E) iTCO_wdt(E) iTCO_vendor_support(E) intel_rapl(E) x86_pkg_temp_thermal(E) kvm_intel(E) kvm(E) irqbypass(E) crct10dif_pclmul(E) crc32_pclmul(E) crc32c_intel(E) ghash_clmulni_intel(E) aesni_intel(E) iwlmvm(E) aes_x86_64(E) crypto_simd(E) mac80211(E) cryptd(E) glue_helper(E) snd_hda_intel(E) snd_hda_codec(E) iwlwifi(E) snd_hwdep(E) psmouse(E) snd_hda_core(E) snd_pcm(E) serio_raw(E) sdhci_pci(E) pcspkr(E) snd_timer(E) ehci_pci(E) e1000e(E) i2c_i801(E) ehci_hcd(E) snd(E) sg(E
 ) i915(E) lpc_ich(E)
>> [   60.007366]  ptp(E) usbcore(E) cfg80211(E) mfd_core(E) pps_core(E) shpchp(E) ac(E) battery(E) tpm_tis(E) tpm_tis_core(E) evdev(E) tpm(E) parport_pc(E) ppdev(E) lp(E) parport(E) ip_tables(E) x_tables(E) autofs4(E)
>> [   60.007474] CPU: 2 PID: 33 Comm: kworker/2:1 Tainted: G            E   4.12.3-nr44-normandy-r1500619820+ #1
>> [   60.007524] Hardware name: LENOVO 4291LR7/4291LR7, BIOS CBET4000 4.6-810-g50522254fb 07/21/2017
>> [   60.007580] Workqueue: usb_hub_wq hub_event [usbcore]
>> [   60.007609] task: ffff8c882b716040 task.stack: ffffb8e800d84000
>> [   60.007644] RIP: 0010:qmi_wwan_disconnect+0x25/0xc0 [qmi_wwan]
>> [   60.007678] RSP: 0018:ffffb8e800d87b38 EFLAGS: 00010246
>> [   60.007711] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 0000000000000000
>> [   60.007752] RDX: 0000000000000001 RSI: ffff8c8824f3f1d0 RDI: ffff8c8824ef6400
>> [   60.007792] RBP: ffff8c8824ef6400 R08: 0000000000000000 R09: 0000000000000000
>> [   60.007833] R10: ffffb8e800d87780 R11: 0000000000000011 R12: ffffffffc07ea0e8
>> [   60.007874] R13: ffff8c8824e2e000 R14: ffff8c8824e2e098 R15: 0000000000000000
>> [   60.007915] FS:  0000000000000000(0000) GS:ffff8c8835300000(0000) knlGS:0000000000000000
>> [   60.007960] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>> [   60.007994] CR2: 00000000000000e0 CR3: 0000000229ca5000 CR4: 00000000000406e0
>> [   60.008035] Call Trace:
>> [   60.008065]  ? usb_unbind_interface+0x71/0x270 [usbcore]
>> [   60.008101]  ? device_release_driver_internal+0x154/0x210
>> [   60.008135]  ? qmi_wwan_unbind+0x6d/0xc0 [qmi_wwan]
>> [   60.008168]  ? usbnet_disconnect+0x6c/0xf0 [usbnet]
>> [   60.008194]  ? qmi_wwan_disconnect+0x87/0xc0 [qmi_wwan]
>> [   60.008232]  ? usb_unbind_interface+0x71/0x270 [usbcore]
>> [   60.008264]  ? device_release_driver_internal+0x154/0x210
>> [   60.008296]  ? bus_remove_device+0xf5/0x160
>> [   60.008324]  ? device_del+0x1dc/0x310
>> [   60.008355]  ? usb_remove_ep_devs+0x1b/0x30 [usbcore]
>> [   60.008393]  ? usb_disable_device+0x93/0x250 [usbcore]
>> [   60.008430]  ? usb_disconnect+0x90/0x260 [usbcore]
>> [   60.008468]  ? hub_event+0x1d9/0x14a0 [usbcore]
>> [   60.008500]  ? process_one_work+0x175/0x370
>> [   60.008528]  ? worker_thread+0x4a/0x380
>> [   60.008555]  ? kthread+0xfc/0x130
>> [   60.008579]  ? process_one_work+0x370/0x370
>> [   60.008606]  ? kthread_park+0x60/0x60
>> [   60.008631]  ? ret_from_fork+0x22/0x30
>> [   60.008656] Code: 66 0f 1f 44 00 00 66 66 66 66 90 55 48 89 fd 53 48 83 ec 10 48 8b 9f c8 00 00 00 65 48 8b 04 25 28 00 00 00 48 89 44 24 08 31 c0 <f6> 83 e0 00 00 00 02 74 51 e8 0d b3 2b cd 85 c0 74 67 48 8b bb
>> [   60.011925] RIP: qmi_wwan_disconnect+0x25/0xc0 [qmi_wwan] RSP: ffffb8e800d87b38
>> [   60.013564] CR2: 00000000000000e0
>> [   60.022125] ---[ end trace e536b59f45bc0f25 ]---
>> [   60.025385] IPv6: ADDRCONF(NETDEV_UP): wlp2s0: link is not ready
>>
>> If I attempt a second rmmod, the process hangs. If I attempt it on 4.11.x it works as expected:
>>
>> [   16.897783] fuse init (API version 7.26)
>> [   68.073552] usbcore: deregistering interface driver qmi_wwan
>> [   68.075808] qmi_wwan 2-1.4:1.6 wwp0s29u1u4i6: unregister 'qmi_wwan' usb-0000:00:1d.0-1.4, WWAN/QMI device
>> [   72.431403] e1000e: enp0s25 NIC Link is Down
>>
>> So I'm pretty certain it's not coreboot causing the issue.
>
> Thanks a lot for the report!  Just one question: Does your modem have
> separate control and data interfaces? If so, then I believe the
> attached patch will fix the issue.  Are you able to test it?
>
> If the modem use the more common cobined interface model. then I need to
> investigate this further..
>
>
> Bjørn
