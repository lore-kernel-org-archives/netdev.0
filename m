From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 67141] New: WARNING at net/ipv4/tcp_output.c:1065
 tcp_fragment
Date: Mon, 16 Dec 2013 16:00:46 -0800
Message-ID: <20131216160046.04d4db4d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:43216 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863Ab3LQAAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 19:00:49 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so6173750pbc.35
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 16:00:49 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id m2sm29269186pbn.19.2013.12.16.16.00.48
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 16:00:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 16 Dec 2013 15:50:57 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 67141] New: WARNING at net/ipv4/tcp_output.c:1065 tcp_fragment


https://bugzilla.kernel.org/show_bug.cgi?id=67141

            Bug ID: 67141
           Summary: WARNING at net/ipv4/tcp_output.c:1065 tcp_fragment
           Product: Networking
           Version: 2.5
    Kernel Version: 3.11.10 and 3.12.4
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: cardi@wifihr.net
        Regression: No

After upgrading to 3.11.10 from 3.2.23 these kind of stack traces started
appearing on console:

[18616.401828] WARNING: CPU: 1 PID: 1977 at net/ipv4/tcp_output.c:1061
tcp_fragment+0x32e/0x340()
[18616.401866] Modules linked in: xt_nat netconsole configfs xt_multiport
xt_recent xt_state dummy cmac af_key crypto_null hmac sha256_generic
sha512_generic rmd160 xcbc cbc des_generic cast5_avx_x86_64 cast5_generic
cast_common blowfish_x86_64 blowfish_generic blowfish_common serpent_avx_x86_64
serpent_sse2_x86_64 serpent_generic camellia_generic camellia_aesni_avx_x86_64
camellia_x86_64 twofish_x86_64_3way twofish_x86_64 xts twofish_generic
twofish_common ctr deflate zlib_deflate iptable_filter iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 ah4 esp4 ipcomp xfrm_ipcomp
xfrm4_tunnel tunnel4 xfrm_user xfrm_algo xfrm4_mode_tunnel xfrm6_mode_tunnel
authenc iptable_mangle sch_htb sch_sfq pptp gre l2tp_ppp pppox l2tp_netlink
l2tp_core sha1_ssse3 sha1_generic arc4 ecb ppp_mppe ppp_generic slhc
xfrm4_mode_transport tun cls_u32 xt_REDIRECT nf_nat nf_tproxy_core xt_tcpudp
xt_conntrack nf_conntrack xt_NFLOG nfnetlink_log iptable_raw ip_tables
xt_hashlimit ip_set_hash_ip xt_set ip_set nfnetlink xt_time x_tables loop
joydev x86_pkg_temp_thermal hid_generic coretemp kvm_intel kvm usbhid hid
crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel ablk_helper tpm_tis
snd_pcm cryptd lrw tpm hpilo mperf evdev tpm_bios snd_timer snd gf128mul
soundcore glue_helper aes_x86_64 hpwdt snd_page_alloc microcode pcspkr lpc_ich
psmouse serio_raw button mfd_core processor acpi_power_meter ehci_pci ext4 jbd2
mbcache crc16 sd_mod crc_t10dif ahci uhci_hcd libahci ehci_hcd libata usbcore
scsi_mod tg3 usb_common libphy ptp pps_core thermal thermal_sys
[18616.402934] CPU: 1 PID: 1977 Comm: openvpn Tainted: G        W    3.11.10 #2
[18616.402971] Hardware name: HP ProLiant DL320e Gen8, BIOS J05 12/10/2012
[18616.402995]  0000000000000425 ffff88020b423938 ffffffff814afecc
0000000000000425
[18616.403049]  0000000000000000 ffff88020b423978 ffffffff8105e277
ffff8801f27f8b80
[18616.403109]  ffff8801f101e080 0000000000000060 0000000000000020
ffff8801f5a311c0
[18616.403167] Call Trace:
[18616.403187]  <IRQ>  [<ffffffff814afecc>] dump_stack+0x49/0x5d
[18616.403226]  [<ffffffff8105e277>] warn_slowpath_common+0x87/0xb0
[18616.403252]  [<ffffffff8105e2b5>] warn_slowpath_null+0x15/0x20
[18616.403276]  [<ffffffff81417b1e>] tcp_fragment+0x32e/0x340
[18616.403301]  [<ffffffff8140f475>] tcp_mark_head_lost+0x1a5/0x2d0
[18616.403326]  [<ffffffff8140f5f0>] tcp_update_scoreboard+0x50/0x80
[18616.403351]  [<ffffffff81412984>] tcp_fastretrans_alert+0x5d4/0xae0
[18616.403376]  [<ffffffff814148ce>] tcp_ack+0x6ee/0xf10
[18616.403402]  [<ffffffff8144aba2>] ? _decode_session4+0x2c2/0x2e0
[18616.403428]  [<ffffffff81415a4c>] tcp_rcv_established+0x2cc/0x810
[18616.403456]  [<ffffffff8141e955>] tcp_v4_do_rcv+0x255/0x4f0
[18616.403481]  [<ffffffff81420399>] tcp_v4_rcv+0x609/0x760
[18616.403506]  [<ffffffff813fc5c0>] ? ip_rcv+0x350/0x350
[18616.403530]  [<ffffffff813f56c5>] ? nf_hook_slow+0x75/0x160
[18616.403554]  [<ffffffff813fc5c0>] ? ip_rcv+0x350/0x350
[18616.403578]  [<ffffffff813fc68e>] ip_local_deliver_finish+0xce/0x250
[18616.403604]  [<ffffffff813fc858>] ip_local_deliver+0x48/0x80
[18616.403629]  [<ffffffff813fbee9>] ip_rcv_finish+0x119/0x360
[18616.403653]  [<ffffffff813fc4a3>] ip_rcv+0x233/0x350
[18616.403678]  [<ffffffff813c890e>] __netif_receive_skb_core+0x5fe/0x7a0
[18616.403705]  [<ffffffff813c8ad2>] __netif_receive_skb+0x22/0x70
[18616.403729]  [<ffffffff813c8c23>] process_backlog+0x103/0x200
[18616.403755]  [<ffffffff813c944a>] net_rx_action+0x10a/0x280
[18616.403779]  [<ffffffff8106309f>] __do_softirq+0xef/0x280
[18616.403805]  [<ffffffff814bdd1c>] call_softirq+0x1c/0x30
[18616.403827]  <EOI>  [<ffffffff81015815>] do_softirq+0x65/0xa0
[18616.403864]  [<ffffffff813c74e8>] netif_rx_ni+0x28/0x30
[18616.403891]  [<ffffffffa03e101f>] tun_get_user+0x31f/0x860 [tun]
[18616.403917]  [<ffffffff81010000>] ?
perf_trace_xen_cpu_write_gdt_entry+0xf0/0xf0
[18616.403958]  [<ffffffffa03e1655>] tun_chr_aio_write+0x85/0xa0 [tun]
[18616.403985]  [<ffffffffa03dfe4f>] ? tun_chr_aio_read+0x9f/0xb0 [tun]
[18616.404012]  [<ffffffff8117b53a>] do_sync_write+0x7a/0xb0
[18616.404036]  [<ffffffff8117b7c8>] ? rw_verify_area+0x58/0xe0
[18616.404061]  [<ffffffff8117b918>] vfs_write+0xc8/0x170
[18616.404085]  [<ffffffff8117be6a>] SyS_write+0x5a/0xa0
[18616.404110]  [<ffffffff814bc469>] system_call_fastpath+0x16/0x1b
[18616.404134] ---[ end trace 96c92912ac0c5c66 ]---

Setting /proc/sys/net/ipv4/tcp_fack to 0 resolves the issue but I'm not sure if
that's the way to go, better if this gets fixed :)
These warnings appear if there's much TCP load on the server and if that load
is related to the tun interface. They're the same every time they appear so
there's no point in pasting multiple stack traces. OpenVPN version is 2.3.0,
running in TAP mode and operating the tun device.
The good thing is that this kind of TCP load used to make the server panic
under 3.2.23 kernel with a similar stack trace to this one:

[7400083.464717] skb_over_panic: text:ffffffff812e6800 len:848 put:512
head:ffff8801e27ed800 data:ffff8801e27edd30 tail:0x880 end:0x680 dev:<NULL>
[7400083.464783] ------------[ cut here ]------------
[7400083.464806] kernel BUG at net/core/skbuff.c:207!
[7400083.464828] invalid opcode: 0000 [#1] SMP
[7400083.464855] CPU 1
[7400083.464861] Modules linked in: mii dca netconsole configfs xt_recent
xt_RAWNAT(O) compat_xtables(O) ip6_tables dummy xt_multiport xt_state af_key
crypto_null hmac
sha256_generic sha512_generic rmd160 xcbc cbc des_generic cast5 blowfish_x86_64
blowfish_generic blowfish_common serpent camellia twofish_x86_64_3way
twofish_x86_64 two
fish_generic twofish_common ctr deflate zlib_deflate iptable_filter iptable_nat
ah4 esp4 ipcomp xfrm_ipcomp xfrm4_tunnel tunnel4 xfrm_user xfrm4_mode_tunnel
xfrm6_mode_
tunnel authenc iptable_mangle sch_htb sch_sfq pptp gre l2tp_ppp pppox
l2tp_netlink l2tp_core sha1_ssse3 sha1_generic arc4 ecb ppp_mppe ppp_generic
slhc xfrm4_mode_trans
port tun cls_u32 ipt_REDIRECT nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_tproxy_core xt_tcpudp xt_conntrack xt_NFLOG nfnetlink_log iptable_raw
ip_tables xt_NOTRACK nf_c
onntrack xt_hashlimit ip_set_hash_ip xt_quota2(O) xt_set ip_set nfnetlink
xt_time x_tables coretemp crc32c_intel ghash_clmulni_intel acpi_power_meter
hpwdt hpilo tpm_ti
s tpm tpm_bios aesni_intel snd_pcm snd_timer snd soundcore snd_page_alloc
cryptd aes_x86_64 aes_generic psmouse evdev pcspkr joydev serio_raw button
container processor
 ext4 mbcache jbd2 crc16 sd_mod crc_t10dif usbhid hid uhci_hcd ahci libahci
libata scsi_mod tg3(O) ptp pps_core ehci_hcd usbcore thermal usb_common
thermal_sys [last un
loaded: 3c59x]
[7400083.465717]
[7400083.465736] Pid: 32445, comm: openvpn Tainted: G           O 3.2.23 #1 HP
ProLiant DL320e Gen8
[7400083.465783] RIP: 0010:[<ffffffff8129da7f>]  [<ffffffff8129da7f>]
skb_put+0x7a/0x89
[7400083.465825] RSP: 0000:ffff88020ae23a80  EFLAGS: 00010286
[7400083.465848] RAX: 0000000000000099 RBX: ffff8801117bc800 RCX:
0000000049be49be
[7400083.465884] RDX: 0000000000000000 RSI: 0000000000000046 RDI:
0000000000000246
[7400083.465920] RBP: ffff8801e27436c0 R08: 00000000000000bd R09:
0000000000bd0004
[7400083.465956] R10: 00000000ffffffff R11: 0000000000000000 R12:
ffff8801e27436e8
[7400083.465992] R13: ffff8801292db240 R14: ffff88010caff000 R15:
00000000000000b0
[7400083.466029] FS:  00007f5338955700(0000) GS:ffff88020ae20000(0000)
knlGS:0000000000000000
[7400083.466066] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[7400083.466089] CR2: 0000000004522000 CR3: 00000001f693d000 CR4:
00000000001406e0
[7400083.466125] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[7400083.466161] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[7400083.466197] Process openvpn (pid: 32445, threadinfo ffff8801ecc80000, task
ffff8802006783c0)
[7400083.466235] Stack:
[7400083.466253]  0000000000000880 0000000000000680 ffffffff814de165
ffff8801117bc800
[7400083.466303]  ffff8801e27436c0 ffffffff812e6800 ffff880100000200
ffff8801117bc8e8
[7400083.466351]  ffff8801117bc908 0000015000000003 ffff8801117bc908
ffff8801117bc800
[7400083.466400] Call Trace:
[7400083.466419]  <IRQ>
[7400083.466443]  [<ffffffff812e6800>] ? tcp_retransmit_skb+0x291/0x58b
[7400083.466468]  [<ffffffff812e6cff>] ? tcp_xmit_retransmit_queue+0x195/0x231
[7400083.466493]  [<ffffffff812e3643>] ? tcp_ack+0x18ad/0x1a89
[7400083.466517]  [<ffffffff812e17fe>] ? tcp_validate_incoming+0x68/0x255
[7400083.466541]  [<ffffffff812e3ddb>] ? tcp_rcv_established+0x5bc/0x68d
[7400083.466567]  [<ffffffff812eb228>] ? tcp_v4_do_rcv+0x1bd/0x3ee
[7400083.466592]  [<ffffffff812ec896>] ? tcp_v4_rcv+0x450/0x6fe
[7400083.466616]  [<ffffffff812cfba5>] ? T.1004+0x4f/0x4f
[7400083.466641]  [<ffffffff812a9355>] ? napi_skb_finish+0x1c/0x31
[7400083.466666]  [<ffffffff812cfce2>] ? ip_local_deliver_finish+0x13d/0x1aa
[7400083.466691]  [<ffffffff812a8e9d>] ? __netif_receive_skb+0x452/0x496
[7400083.466715]  [<ffffffff812a8fcd>] ? process_backlog+0xec/0x1c7
[7400083.466739]  [<ffffffff812a991a>] ? net_rx_action+0xa8/0x207
[7400083.466764]  [<ffffffff8104f1b2>] ? __do_softirq+0xc4/0x1a0
[7400083.466789]  [<ffffffff81097ac9>] ? handle_irq_event_percpu+0x166/0x184
[7400083.466814]  [<ffffffff8136dcec>] ? call_softirq+0x1c/0x30
[7400083.466839]  [<ffffffff8100fa3f>] ? do_softirq+0x3f/0x79
[7400083.466863]  [<ffffffff8104ef82>] ? irq_exit+0x44/0xb5
[7400083.466886]  [<ffffffff8100f38a>] ? do_IRQ+0x94/0xaa
[7400083.466909]  [<ffffffff8136676e>] ? common_interrupt+0x6e/0x6e
[7400083.466932]  <EOI>
[7400083.466955]  [<ffffffff8136ba92>] ? system_call_fastpath+0x16/0x1b
[7400083.466979] Code: 8b 57 70 48 89 44 24 10 8b 87 e0 00 00 00 48 89 44 24 08
8b bf dc 00 00 00 31 c0 48 89 3c 24 48 c7 c7 d9 1a 50 81 e8 0f 6d 0c 00 <0f> 0b
eb fe 89 c0 48 83 c4 28 49 8d 04 00 c3 41 57


Otherwise, without the tun interface involved, the warning cannot be observed,
nor was there any kind of a panic by the kernel in the 3.2.23 version. I guess
these two, the panic and the warning are related.

Here's the stack trace of 3.12.4:

[  344.928972] WARNING: CPU: 1 PID: 2048 at net/ipv4/tcp_output.c:1065
tcp_fragment+0x32e/0x340()
[  344.929711] Modules linked in: xt_nat netconsole configfs af_packet
xt_multiport xt_recent xt_state dummy cmac aesni_intel aes_x86_64 crc32c_intel
af_key crypto_null sha1_ssse3 sha256_generic sha512_generic rmd160 xcbc cbc
des_generic cast5_avx_x86_64 cast5_generic cast_common blowfish_x86_64
blowfish_generic blowfish_common serpent_avx_x86_64 serpent_sse2_x86_64
serpent_generic camellia_generic camellia_aesni_avx_x86_64 ablk_helper cryptd
camellia_x86_64 twofish_x86_64_3way twofish_x86_64 glue_helper lrw xts gf128mul
twofish_generic twofish_common ctr deflate iptable_filter iptable_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 ah4 esp4 ipcomp xfrm_ipcomp
xfrm4_tunnel tunnel4 xfrm_user xfrm_algo xfrm4_mode_tunnel xfrm6_mode_tunnel
authenc iptable_mangle sch_htb sch_sfq pptp gre l2tp_ppp pppox l2tp_netlink
l2tp_core ipv6 arc4 ecb ppp_mppe ppp_generic slhc xfrm4_mode_transport tun
cls_u32 xt_REDIRECT nf_nat xt_tcpudp xt_conntrack nf_conntrack xt_NFLOG
nfnetlink_log iptable_raw ip_tables xt_hashlimit ip_set_hash_ip xt_set ip_set
nfnetlink xt_time x_tables loop joydev hid_generic usbhid mgag200 ttm
drm_kms_helper drm gpio_ich pcspkr i2c_algo_bit i2c_core psmouse tpm_tis hpilo
tpm tpm_bios hpwdt serio_raw lpc_ich ehci_pci rtc_cmos ipmi_si ipmi_msghandler
evdev acpi_power_meter button ext4 jbd2 mbcache crc16 sd_mod ahci libahci
libata scsi_mod tg3 ptp pps_core uhci_hcd ehci_hcd thermal
[  344.939748] CPU: 1 PID: 2048 Comm: openvpn Not tainted 3.12.4 #3
[  344.940755] Hardware name: HP ProLiant DL320e Gen8, BIOS J05 12/10/2012
[  344.941762]  0000000000000429 ffff88020b423928 ffffffff814de004
0000000000000429
[  344.942788]  0000000000000000 ffff88020b423968 ffffffff81060287
ffff88020b4239c8
[  344.943816]  ffff8800eaf10000 0000000000000180 0000000000000100
ffff880200302a00
[  344.944852] Call Trace:
[  344.945869]  <IRQ>  [<ffffffff814de004>] dump_stack+0x49/0x5d
[  344.946919]  [<ffffffff81060287>] warn_slowpath_common+0x87/0xb0
[  344.947959]  [<ffffffff810602c5>] warn_slowpath_null+0x15/0x20
[  344.949013]  [<ffffffff8148366e>] tcp_fragment+0x32e/0x340
[  344.950062]  [<ffffffff8147af95>] tcp_mark_head_lost+0x1a5/0x2d0
[  344.951110]  [<ffffffff8147b110>] tcp_update_scoreboard+0x50/0x80
[  344.952070]  [<ffffffff8147e1dd>] tcp_fastretrans_alert+0x65d/0xab0
[  344.952658]  [<ffffffff81480485>] tcp_ack+0xad5/0x1180
[  344.953279]  [<ffffffff812f490c>] ? add_interrupt_randomness+0x3c/0x190
[  344.953867]  [<ffffffff8148148c>] tcp_rcv_established+0x2cc/0x810
[  344.954461]  [<ffffffff8148a4e5>] tcp_v4_do_rcv+0x245/0x4e0
[  344.955053]  [<ffffffff8148bef6>] tcp_v4_rcv+0x5f6/0x750
[  344.955644]  [<ffffffff81467f10>] ? ip_rcv+0x3a0/0x3a0
[  344.956236]  [<ffffffff81460f85>] ? nf_hook_slow+0x75/0x160
[  344.956817]  [<ffffffff81467f10>] ? ip_rcv+0x3a0/0x3a0
[  344.957414]  [<ffffffff81467fc2>] ip_local_deliver_finish+0xb2/0x230
[  344.957969]  [<ffffffff81468188>] ip_local_deliver+0x48/0x80
[  344.958521]  [<ffffffff814677e9>] ip_rcv_finish+0x119/0x360
[  344.959073]  [<ffffffff81467dff>] ip_rcv+0x28f/0x3a0
[  344.959622]  [<ffffffff81433ffe>] __netif_receive_skb_core+0x5fe/0x7a0
[  344.960176]  [<ffffffff8101c2c9>] ? sched_clock+0x9/0x10
[  344.960726]  [<ffffffff814341c2>] __netif_receive_skb+0x22/0x70
[  344.961306]  [<ffffffff8143431b>] process_backlog+0x10b/0x210
[  344.961848]  [<ffffffff81434b5a>] net_rx_action+0x10a/0x280
[  344.962392]  [<ffffffff810653bf>] __do_softirq+0xff/0x2d0
[  344.962936]  [<ffffffff814e48dc>] call_softirq+0x1c/0x30
[  344.963476]  <EOI>  [<ffffffff81016395>] do_softirq+0x65/0xa0
[  344.964020]  [<ffffffff81432c28>] netif_rx_ni+0x28/0x30
[  344.964567]  [<ffffffffa04a0464>] tun_get_user+0x314/0x830 [tun]
[  344.965148]  [<ffffffffa04a0a75>] tun_chr_aio_write+0x85/0xa0 [tun]
[  344.965683]  [<ffffffff8117487a>] do_sync_write+0x5a/0x90
[  344.966204]  [<ffffffff81174af8>] ? rw_verify_area+0x58/0xe0
[  344.966710]  [<ffffffff81174c48>] vfs_write+0xc8/0x170
[  344.967199]  [<ffffffff8117523a>] SyS_write+0x5a/0xa0
[  344.967670]  [<ffffffff814e3247>] tracesys+0xdd/0xe2
[  344.968124] ---[ end trace d8bbaf64668174aa ]---

As you can see, the same stuff again. I guess the problem is in the
tcp_mark_head_lost somewhere, the kernel issues a warning because (packets -
oldcnt) * mss  is greater than skb->len.

--
You are receiving this mail because:
You are the assignee for the bug.
