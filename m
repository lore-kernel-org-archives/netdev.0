From: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
Subject: rfkill rewrite bug
Date: Mon, 13 Apr 2009 20:00:12 +0100
Message-ID: <49E38BBC.5010708@tuffmail.co.uk>
References: <49DCA88E.6060400@tuffmail.co.uk>	 (sfid-20090408_153722_059382_FB44D658) <1239204090.16477.1.camel@johannes.local> <49DCDD2E.80705@tuffmail.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:42964 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbZDMSzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 14:55:25 -0400
Received: by fxm2 with SMTP id 2so2108734fxm.37
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2009 11:55:23 -0700 (PDT)
In-Reply-To: <49DCDD2E.80705@tuffmail.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alan Jenkins wrote:
> Johannes Berg wrote:
>   
>> On Wed, 2009-04-08 at 14:37 +0100, Alan Jenkins wrote:    
>>     
>> You're right, and I'm rewriting rfkill and part of that is changing the
>> maintainer to myself and the list to linux-wireless.
>>   
>>     
>
> Good luck!  I'll try to have a look at your patch, to see how (if) it
> would affect the benighted eeepc-laptop.
>   

I tried the latest patch (#19) from your website, it didn't work so well 
:-).

[   78.301309] BUG: unable to handle kernel NULL pointer dereference at 
(null)
[   78.301326] IP: [<c0279468>] led_trigger_event+0x31/0x40
[   78.301349] *pdpt = 0000000012375001 *pde = 0000000000000000
[   78.301362] Oops: 0000 [#1]
[   78.301369] last sysfs file: /sys/module/backlight/initstate
[   78.301378] Modules linked in: eeepc_laptop(+) rfkill aes_i586 
aes_generic af_packet i915 drm i2c_algo_bit cfbcopyarea cfbimgblt 
cfbfillrect ipv6 joydev arc4 ecb usual_tables(P) snd_hda_codec_realtek 
snd_hda_intel snd_hda_codec snd_hwdep ath5k snd_pcm_oss snd_mixer_oss 
mac80211 psmouse i2c_i801 uhci_hcd led_class serio_raw snd_pcm i2c_core 
pcspkr intel_agp ehci_hcd atl2 cfg80211 usbcore snd_timer snd_page_alloc 
agpgart video backlight output battery ac button processor evdev thermal 
fan ata_generic
[   78.301492]
[   78.301503] Pid: 2904, comm: modprobe Tainted: P           
(2.6.30-rc1-wleeepc #2) 701
[   78.301513] EIP: 0060:[<c0279468>] EFLAGS: 00210286 CPU: 0
[   78.301523] EIP is at led_trigger_event+0x31/0x40
[   78.301532] EAX: df34e618 EBX: 00000000 ECX: df34e618 EDX: 000000ff
[   78.301541] ESI: 000000ff EDI: df34e624 EBP: d2373e44 ESP: d2373e38
[   78.301551]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[   78.301561] Process modprobe (pid: 2904, ti=d2372000 task=d2312400 
task.ti=d2372000)
[   78.301569] Stack:
[   78.301574]  df34e600 e0017f58 df268800 d2373e4c e01692af d2373e5c 
e01695f8 00000001
[   78.301592]  d21f6800 d2373e80 e00178bc 00000000 00000200 00000010 
d22b1280 df268800
[   78.301611]  ffffffed e0019478 d2373e9c c020eff3 df268a04 ffffffda 
df268a04 ffffffed
[   78.301631] Call Trace:
[   78.301638]  [<e01692af>] ? rfkill_led_trigger_event+0x1a/0x1c [rfkill]
[   78.301663]  [<e01695f8>] ? rfkill_set_sw_state+0x53/0x69 [rfkill]
[   78.301685]  [<e00178bc>] ? eeepc_hotk_add+0x2ca/0x3ef [eeepc_laptop]
[   78.301706]  [<c020eff3>] ? acpi_device_probe+0x44/0x127
[   78.301723]  [<c02470a9>] ? driver_probe_device+0x7f/0xf2
[   78.301740]  [<c024715f>] ? __driver_attach+0x43/0x5f
[   78.301753]  [<c024675b>] ? bus_for_each_dev+0x39/0x5a
[   78.301766]  [<c0246f7c>] ? driver_attach+0x14/0x16
[   78.301778]  [<c024711c>] ? __driver_attach+0x0/0x5f
[   78.301791]  [<c0246c5f>] ? bus_add_driver+0xd7/0x1e7
[   78.301804]  [<c0247365>] ? driver_register+0x7b/0xd7
[   78.301822]  [<c02106c9>] ? acpi_bus_register_driver+0x3a/0x3c
[   78.301835]  [<e0011022>] ? eeepc_laptop_init+0x22/0x1b9 [eeepc_laptop]
[   78.301852]  [<c0101131>] ? _stext+0x49/0x10b
[   78.301865]  [<e0011000>] ? eeepc_laptop_init+0x0/0x1b9 [eeepc_laptop]
[   78.301882]  [<c012f3c2>] ? __blocking_notifier_call_chain+0x40/0x4c
[   78.301899]  [<c013a680>] ? sys_init_module+0x87/0x18b
[   78.301915]  [<c0102804>] ? sysenter_do_call+0x12/0x22
[   78.301928] Code: 56 89 d6 53 74 2f 8b 58 0c 8d 78 0c eb 1d 8d 4b c4 
8b 41 08 39 c6 89 c2 0f 46 d6 f6 41 0c 01 89 51 04 75 05 89 c8 ff 51 10 
8b 1b <8b> 03 0f 18 00 90 39 fb 75 d9 5b 5e 5f 5d c3 55 89 e5 56 8d 70
[   78.302018] EIP: [<c0279468>] led_trigger_event+0x31/0x40 SS:ESP 
0068:d2373e38
[   78.302032] CR2: 0000000000000000
[   78.302041] ---[ end trace 3e0b201a788d0ed8 ]---

Regards
Alan
