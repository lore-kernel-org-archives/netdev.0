From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: SunHME: trying to enable netconsole/netpolling
Date: Wed, 3 Sep 2008 20:26:54 +0400
Message-ID: <a4423d670809030926v369ed065w437d35caa6b016a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_16445_22528266.1220459214754"
To: "David Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:58432 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552AbYICQ04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 12:26:56 -0400
Received: by an-out-0708.google.com with SMTP id d40so505481and.103
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2008 09:26:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_16445_22528266.1220459214754
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David

Can you please advice
I am a newbie here.
I am trying to enable netconsole output with sunhme card,
I found that poll_controller is not defined and defined it
as it is defined in other drivers (just to watch if it will work, I
dont understand this code yet)
My patch is in attach.
My card is connected to PCI bus.

netconsole is working now!
(and network is  still working too)
but I get the following warning:

[   27.584439] =================================
[   27.602571] [ INFO: inconsistent lock state ]
[   27.611437] 2.6.27-rc5-next-20080903-dirty #1
[   27.620233] ---------------------------------
[   27.628938] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
[   27.637836] swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   27.646757]  (_xmit_ETHER#2){-+..}, at: [<000000000063724c>]
dev_watchdog+0x44/0x230
[   27.656358] {softirq-on-W} state was registered at:
[   27.665546]   [<0000000000473da0>] trace_hardirqs_on+0x10/0x20
[   27.674958]   [<00000000006a066c>] _spin_unlock_irq+0x28/0x5c
[   27.684373]   [<00000000005d53d0>] happy_meal_start_xmit+0x340/0x360
[   27.693771]   [<0000000000634ea4>] netpoll_send_skb+0xdc/0x1b0
[   27.703068]   [<0000000000635178>] netpoll_send_udp+0x200/0x258
[   27.712257]   [<00000000005d59dc>] write_msg+0xa0/0xfc
[   27.721395]   [<0000000000451480>] __call_console_drivers+0x8c/0xa8
[   27.730540]   [<0000000000451540>] _call_console_drivers+0xa4/0xb4
[   27.739765]   [<00000000004516fc>] release_console_sem+0x1ac/0x280
[   27.748909]   [<00000000004521cc>] register_console+0x318/0x328
[   27.758132]   [<00000000007f8274>] init_netconsole+0x1c0/0x23c
[   27.767227]   [<0000000000426c44>] do_one_initcall+0x44/0x15c
[   27.776348]   [<00000000007e8284>] kernel_init+0x13c/0x1b4
[   27.785316]   [<0000000000427260>] kernel_thread+0x3c/0x54
[   27.794252]   [<0000000000692f08>] rest_init+0x1c/0x84
[   27.803207] irq event stamp: 16998
[   27.811956] hardirqs last  enabled at (16998): [<0000000000473da0>]
trace_hardirqs_on+0x10/0x20
[   27.821176] hardirqs last disabled at (16997): [<000000000047208c>]
trace_hardirqs_off+0x10/0x20
[   27.830357] softirqs last  enabled at (16986): [<0000000000456790>]
__do_softirq+0xc8/0xd8
[   27.839355] softirqs last disabled at (16995): [<000000000042d9e8>]
do_softirq+0x7c/0xbc
[   27.848342]
[   27.848350] other info that might help us debug this:
[   27.865659] 1 lock held by swapper/0:
[   27.874249]  #0:  (&dev->tx_global_lock){-+..}, at:
[<0000000000637224>] dev_watchdog+0x1c/0x230
[   27.883557]
[   27.883565] stack backtrace:
[   27.900584] Call Trace:
[   27.909054]  [00000000004727e4] print_usage_bug+0x1a8/0x1b8
[   27.917585]  [0000000000473230] mark_lock+0x4d8/0xd3c
[   27.925958]  [0000000000474ef0] __lock_acquire+0x728/0x1908
[   27.934287]  [000000000047612c] lock_acquire+0x5c/0x74
[   27.942577]  [00000000006a0888] _spin_lock+0x30/0x48
[   27.950778]  [000000000063724c] dev_watchdog+0x44/0x230
[   27.958963]  [000000000045ac28] run_timer_softirq+0x170/0x1ec
[   27.967045]  [000000000045672c] __do_softirq+0x64/0xd8
[   27.975165]  [000000000042d9e8] do_softirq+0x7c/0xbc
[   27.983223]  [00000000004561ec] irq_exit+0x54/0xc0
[   27.991361]  [000000000043162c] timer_interrupt+0x7c/0x94
[   27.999331]  [0000000000426a3c] sys_call_table+0x530/0x6f4
[   28.007211]  [00000000004281f8] cpu_idle+0xac/0xec
[   28.014989]  [0000000000692f60] rest_init+0x74/0x84
[   28.022721]  [00000000007e88b4] start_kernel+0x2f4/0x304
[   28.030386]  [00000000006949e0] tlb_fixup_done+0x88/0x90

------=_Part_16445_22528266.1220459214754
Content-Type: text/x-patch; name=sunhme.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fko4um1p0
Content-Disposition: attachment; filename=sunhme.patch

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3N1bmhtZS5jIGIvZHJpdmVycy9uZXQvc3VuaG1lLmMK
aW5kZXggZjFlYmViNS4uMzczM2NkNCAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvc3VuaG1lLmMK
KysrIGIvZHJpdmVycy9uZXQvc3VuaG1lLmMKQEAgLTIxMjMsNiArMjEyMywxMyBAQCBvdXQ6CiAJ
cmV0dXJuIElSUV9IQU5ETEVEOwogfQogCisjaWZkZWYgQ09ORklHX05FVF9QT0xMX0NPTlRST0xM
RVIKK3N0YXRpYyB2b2lkIGhhcHB5X21lYWxfcG9sbF9jb250cm9sbGVyKHN0cnVjdCBuZXRfZGV2
aWNlICpkZXYpCit7CisJaGFwcHlfbWVhbF9pbnRlcnJ1cHQoZGV2LT5pcnEsIGRldik7Cit9Cisj
ZW5kaWYKKwogI2lmZGVmIENPTkZJR19TQlVTCiBzdGF0aWMgaXJxcmV0dXJuX3QgcXVhdHRyb19z
YnVzX2ludGVycnVwdChpbnQgaXJxLCB2b2lkICpjb29raWUpCiB7CkBAIC0yNzYwLDYgKzI3Njcs
OSBAQCBzdGF0aWMgaW50IF9fZGV2aW5pdCBoYXBweV9tZWFsX3NidXNfcHJvYmVfb25lKHN0cnVj
dCBvZl9kZXZpY2UgKm9wLCBpbnQgaXNfcWZlKQogCWRldi0+dHhfdGltZW91dCA9ICZoYXBweV9t
ZWFsX3R4X3RpbWVvdXQ7CiAJZGV2LT53YXRjaGRvZ190aW1lbyA9IDUqSFo7CiAJZGV2LT5ldGh0
b29sX29wcyA9ICZobWVfZXRodG9vbF9vcHM7CisjaWZkZWYgQ09ORklHX05FVF9QT0xMX0NPTlRS
T0xMRVIKKyAgICAgICAgZGV2LT5wb2xsX2NvbnRyb2xsZXIgPSBoYXBweV9tZWFsX3BvbGxfY29u
dHJvbGxlcjsKKyNlbmRpZgogCiAJLyogSGFwcHkgTWVhbCBjYW4gZG8gaXQgYWxsLi4uICovCiAJ
ZGV2LT5mZWF0dXJlcyB8PSBORVRJRl9GX1NHIHwgTkVUSUZfRl9IV19DU1VNOwpAQCAtMzA4OSw2
ICszMDk5LDkgQEAgc3RhdGljIGludCBfX2RldmluaXQgaGFwcHlfbWVhbF9wY2lfcHJvYmUoc3Ry
dWN0IHBjaV9kZXYgKnBkZXYsCiAJZGV2LT5ldGh0b29sX29wcyA9ICZobWVfZXRodG9vbF9vcHM7
CiAJZGV2LT5pcnEgPSBwZGV2LT5pcnE7CiAJZGV2LT5kbWEgPSAwOworI2lmZGVmIENPTkZJR19O
RVRfUE9MTF9DT05UUk9MTEVSCisgICAgICAgIGRldi0+cG9sbF9jb250cm9sbGVyID0gaGFwcHlf
bWVhbF9wb2xsX2NvbnRyb2xsZXI7CisjZW5kaWYKIAogCS8qIEhhcHB5IE1lYWwgY2FuIGRvIGl0
IGFsbC4uLiAqLwogCWRldi0+ZmVhdHVyZXMgfD0gTkVUSUZfRl9TRyB8IE5FVElGX0ZfSFdfQ1NV
TTsK
------=_Part_16445_22528266.1220459214754--
