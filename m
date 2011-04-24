From: Held Bernhard <berny156@gmx.de>
Subject: Oops in 2.6.39 include/net/dst.h: dst_metrics_write_ptr() running
 l2tp over ipsec
Date: Mon, 25 Apr 2011 00:37:13 +0200
Message-ID: <4DB4A619.9080600@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:46657 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757859Ab1DXWhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 18:37:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm starting l2tp over ipsec (racoon, openl2tp) in a little script to 
establish a VPN to my company. 2.6.38.x runs fine, but since 2.6.39-rc1 
(exactly commit 62fa8a "net: Implement read-only protection and COW'ing 
of metrics.") the kernel throws an oops. openl2tp is killed; after a 2nd 
start of openl2tp the VPN is established and my PC continues to run 
normally. The oops is 100% reproducible.

[  101.620985] BUG: unable to handle kernel NULL pointer dereference at 
           (null)
[  101.621050] IP: [<          (null)>]           (null)
[  101.621084] PGD 6e53c067 PUD 3dd6a067 PMD 0
[  101.621122] Oops: 0010 [#1] SMP
[  101.621153] last sysfs file: /sys/devices/virtual/ppp/ppp/uevent
[  101.621192] CPU 2
[  101.621206] Modules linked in: l2tp_ppp pppox ppp_generic slhc 
l2tp_netlink l2tp_core deflate zlib_deflate twofish_x86_64 
twofish_common des_generic cbc ecb sha1_generic hmac af_key 
iptable_filter snd_pcm_oss snd_mixer_oss snd_seq snd_seq_device loop 
snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec 
snd_pcm snd_timer snd i2c_i801 iTCO_wdt psmouse soundcore snd_page_alloc 
evdev uhci_hcd ehci_hcd thermal
[  101.621552]
[  101.621567] Pid: 5129, comm: openl2tpd Not tainted 2.6.39-rc4-Quad #3 
Gigabyte Technology Co., Ltd. G33-DS3R/G33-DS3R
[  101.621637] RIP: 0010:[<0000000000000000>]  [<          (null)>]   (null)
[  101.621684] RSP: 0018:ffff88003ddeba60  EFLAGS: 00010202
[  101.621716] RAX: ffff88003ddb5600 RBX: ffff88003ddb5600 RCX: 
0000000000000020
[  101.621758] RDX: ffffffff81a69a00 RSI: ffffffff81b7ee61 RDI: 
ffff88003ddb5600
[  101.621800] RBP: ffff8800537cd900 R08: 0000000000000000 R09: 
ffff88003ddb5600
[  101.621840] R10: 0000000000000005 R11: 0000000000014b38 R12: 
ffff88003ddb5600
[  101.621881] R13: ffffffff81b7e480 R14: ffffffff81b7e8b8 R15: 
ffff88003ddebad8
[  101.621924] FS:  00007f06e4182700(0000) GS:ffff88007fd00000(0000) 
knlGS:0000000000000000
[  101.621971] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  101.622005] CR2: 0000000000000000 CR3: 0000000045274000 CR4: 
00000000000006e0
[  101.622046] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[  101.622087] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[  101.622129] Process openl2tpd (pid: 5129, threadinfo 
ffff88003ddea000, task ffff88003de9a280)
[  101.622177] Stack:
[  101.622191]  ffffffff81447efa ffff88007d3ded80 ffff88003de9a280 
ffff88007d3ded80
[  101.622245]  0000000000000001 ffff88003ddebbb8 ffffffff8148d5a7 
0000000000000212
[  101.622299]  ffff88003dcea000 ffff88003dcea188 ffffffff00000001 
ffffffff81b7e480
[  101.622353] Call Trace:
[  101.622374]  [<ffffffff81447efa>] ? ipv4_blackhole_route+0x1ba/0x210
[  101.622415]  [<ffffffff8148d5a7>] ? xfrm_lookup+0x417/0x510
[  101.622450]  [<ffffffff8127672a>] ? extract_buf+0x9a/0x140
[  101.622485]  [<ffffffff8144c6a0>] ? __ip_flush_pending_frames+0x70/0x70
[  101.622526]  [<ffffffff8146fbbf>] ? udp_sendmsg+0x62f/0x810
[  101.622562]  [<ffffffff813f98a6>] ? sock_sendmsg+0x116/0x130
[  101.622599]  [<ffffffff8109df58>] ? find_get_page+0x18/0x90
[  101.622633]  [<ffffffff8109fd6a>] ? filemap_fault+0x12a/0x4b0
[  101.622668]  [<ffffffff813fb5c4>] ? move_addr_to_kernel+0x64/0x90
[  101.622706]  [<ffffffff81405d5a>] ? verify_iovec+0x7a/0xf0
[  101.622739]  [<ffffffff813fc772>] ? sys_sendmsg+0x292/0x420
[  101.622774]  [<ffffffff810b994a>] ? handle_pte_fault+0x8a/0x7c0
[  101.622810]  [<ffffffff810b76fe>] ? __pte_alloc+0xae/0x130
[  101.622844]  [<ffffffff810ba2f8>] ? handle_mm_fault+0x138/0x380
[  101.622880]  [<ffffffff81024af9>] ? do_page_fault+0x189/0x410
[  101.622915]  [<ffffffff813fbe03>] ? sys_getsockname+0xf3/0x110
[  101.622952]  [<ffffffff81450c4d>] ? ip_setsockopt+0x4d/0xa0
[  101.622986]  [<ffffffff813f9932>] ? sockfd_lookup_light+0x22/0x90
[  101.623024]  [<ffffffff814b61fb>] ? system_call_fastpath+0x16/0x1b
[  101.623060] Code:  Bad RIP value.
[  101.623090] RIP  [<          (null)>]           (null)
[  101.623125]  RSP <ffff88003ddeba60>
[  101.623146] CR2: 0000000000000000
[  101.650871] ---[ end trace ca3856a7d8e8dad4 ]---
[  101.651011] __sk_free: optmem leakage (160 bytes) detected.

The oops happens in dst_metrics_write_ptr()
include/net/dst.h:124: return dst->ops->cow_metrics(dst, p);

dst->ops->cow_metrics is NULL and causes the oops.

This extremely primitive (and most probably wrong) patch fixes the 
problem for me:

--- include/net/dst.h   2011-04-24 23:10:15.985686594 +0200
+++ include/net/dst.h   2011-04-24 23:44:43.897686223 +0200
@@ -121,7 +121,7 @@ static inline u32 *dst_metrics_write_ptr
         unsigned long p = dst->_metrics;

         if (p & DST_METRICS_READ_ONLY)
-               return dst->ops->cow_metrics(dst, p);
+               return dst->ops->cow_metrics ? 
dst->ops->cow_metrics(dst, p) : NULL;
         return __DST_METRICS_PTR(p);
  }

Please tell me if you need more information!

Thanks,
Bernhard
