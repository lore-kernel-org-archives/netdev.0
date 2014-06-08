From: Mariusz Ceier <mceier+kernel-bugs@gmail.com>
Subject: Re: Fw: [Bug 77481] New: bridge - 2 call traces and "TCP: out of
 memory -- consider tuning tcp_mem"
Date: Sun, 8 Jun 2014 22:44:35 +0200
Message-ID: <CAJTyqKPUpXoq2PszvyTh=9UEh+9==yCP+jUiwRTHpU-NX1hM7A@mail.gmail.com>
References: <20140608095312.21718a66@nehalam.linuxnetplumber.net>
	<1402257570.3645.338.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: mceier+kernel-bugs@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	mceier+kernel-bugs@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:41405 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753744AbaFHUoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 16:44:37 -0400
Received: by mail-wi0-f176.google.com with SMTP id n3so655930wiv.9
        for <netdev@vger.kernel.org>; Sun, 08 Jun 2014 13:44:35 -0700 (PDT)
In-Reply-To: <1402257570.3645.338.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No, I haven't - I tried to reproduce this again on the same kernel,
but it hasn't triggered yet... so I think unless I have some
reproducible steps on this kernel, checking it on newer kernel could
return misleading results.

On 8 June 2014 21:59, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2014-06-08 at 09:53 -0700, Stephen Hemminger wrote:
>>
>> Begin forwarded message:
>>
>> Date: Sun, 8 Jun 2014 02:01:29 -0700
>> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
>> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
>> Subject: [Bug 77481] New: bridge - 2 call traces and "TCP: out of memory -- consider tuning tcp_mem"
>>
>>
>> https://bugzilla.kernel.org/show_bug.cgi?id=77481
>>
>>             Bug ID: 77481
>>            Summary: bridge - 2 call traces and "TCP: out of memory --
>>                     consider tuning tcp_mem"
>>            Product: Networking
>>            Version: 2.5
>>     Kernel Version: 3.14.3
>>           Hardware: All
>>                 OS: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Other
>>           Assignee: shemminger@linux-foundation.org
>>           Reporter: mceier+kernel-bugs@gmail.com
>>         Regression: No
>>
>> Yesterday I have configured bridge(br0) between my wifi interface (wlp3s0) and
>> ethernet interface(enp4s0) using hostapd, and today in dmesg I found 2 call
>> traces, after starting rtorrent on bridge:
>>
>> [175827.356666] WARNING: CPU: 0 PID: 0 at net/core/stream.c:201
>> sk_stream_kill_queues+0xfe/0x126()
>> [175827.356670] Modules linked in: bridge joydev nvidia(PO)
>> x86_pkg_temp_thermal coretemp pcspkr nouveau i2c_i801 snd_hda_codec_realtek
>> snd_hda_codec_hdmi snd_hda_codec_generic mxm_wmi r8169 mii ttm snd_hda_intel
>> snd_hda_codec snd_hwdep rtc_cmos wmi efivarfs xts gf128mul aes_x86_64
>> sha512_generic libiscsi scsi_transport_iscsi tg3 fuse nfs lockd sunrpc jfs
>> hid_sunplus hid_sony hid_samsung hid_pl hid_petalynx hid_monterey hid_microsoft
>> hid_logitech hid_gyration hid_ezkey hid_cypress hid_chicony hid_cherry
>> hid_belkin hid_apple hid_a4tech sl811_hcd aic94xx libsas scsi_transport_sas
>> lpfc qla2xxx scsi_transport_fc megaraid_sas megaraid_mbox megaraid_mm megaraid
>> aacraid sx8 DAC960 cciss 3w_9xxx 3w_xxxx atp870u dc395x qla1280 dmx3191d
>> sym53c8xx gdth advansys initio BusLogic arcmsr aic7xxx aic79xx
>> scsi_transport_spi
>> [175827.356772]  pdc_adma sata_inic162x sata_qstor sata_vsc sata_uli sata_sis
>> sata_sx4 sata_via sata_svw sata_sil24 sata_sil sata_promise pata_sl82c105
>> pata_cs5530 pata_cs5520 pata_via pata_jmicron pata_marvell pata_sis
>> pata_netcell pata_sc1200 pata_pdc202xx_old pata_triflex pata_atiixp pata_opti
>> pata_amd pata_ali pata_it8213 pata_pcmcia pcmcia pcmcia_core pata_ns87415
>> pata_ns87410 pata_serverworks pata_platform pata_artop pata_it821x pata_optidma
>> pata_hpt3x2n pata_hpt3x3 pata_hpt37x pata_hpt366 pata_cmd64x pata_efar
>> pata_rz1000 pata_sil680 pata_radisys pata_pdc2027x pata_mpiix usbhid
>> [175827.356836] CPU: 0 PID: 0 Comm: swapper/0 Tainted: P           O
>> 3.14.3-gentoo #1
>> [175827.356841] Hardware name: ASUSTeK COMPUTER INC. G56JR/G56JR, BIOS
>> G56JR.200 01/13/2014
>> [175827.356845]  0000000000000009 ffff88042ee036f8 ffffffff818532e4
>> 0000000000000103
>> [175827.356853]  0000000000000000 ffff88042ee03738 ffffffff8106c79c
>> ffff8803a25607e0
>> [175827.356859]  ffffffff816e0bff ffff8803a25606c0 ffff8803a2560838
>> ffff880088bdd8e2
>> [175827.356867] Call Trace:
>> [175827.356871]  <IRQ>  [<ffffffff818532e4>] dump_stack+0x4f/0x7c
>> [175827.356887]  [<ffffffff8106c79c>] warn_slowpath_common+0x77/0x91
>> [175827.356896]  [<ffffffff816e0bff>] ? sk_stream_kill_queues+0xfe/0x126
>> [175827.356903]  [<ffffffff8106c7cb>] warn_slowpath_null+0x15/0x17
>> [175827.356910]  [<ffffffff816e0bff>] sk_stream_kill_queues+0xfe/0x126
>> [175827.356918]  [<ffffffff8171af14>] inet_csk_destroy_sock+0x78/0xfe
>> [175827.356925]  [<ffffffff8171cf91>] tcp_done+0x78/0x7d
>> [175827.356931]  [<ffffffff8172581f>] tcp_reset+0x55/0x59
>> [175827.356937]  [<ffffffff81726c81>] tcp_rcv_state_process+0xa05/0xab9
>> [175827.356944]  [<ffffffff81114560>] ? kfree+0xc7/0x125
>> [175827.356952]  [<ffffffff81087612>] ? notifier_call_chain+0x32/0x5c
>> [175827.356960]  [<ffffffff810ed9d0>] ? put_page+0x12/0x23
>> [175827.356967]  [<ffffffff8172c7b6>] tcp_v4_do_rcv+0x2c7/0x313
>> [175827.356973]  [<ffffffff8172f1d6>] ? tcp_v4_rcv+0x6b4/0x734
>> [175827.356979]  [<ffffffff8172eeb9>] tcp_v4_rcv+0x397/0x734
>> [175827.356986]  [<ffffffff81087612>] ? notifier_call_chain+0x32/0x5c
>> [175827.356996]  [<ffffffffa0616009>] ? rtl8169_start_xmit+0x29a/0x716 [r8169]
>> [175827.357003]  [<ffffffff810911ad>] ? update_curr+0x89/0xe1
>> [175827.357010]  [<ffffffff81711b82>] ip_local_deliver_finish+0x10c/0x1ed
>> [175827.357016]  [<ffffffff81711d9d>] ip_local_deliver+0x47/0x78
>> [175827.357022]  [<ffffffff81711a3f>] ip_rcv_finish+0x29e/0x2d5
>> [175827.357028]  [<ffffffff81712075>] ip_rcv+0x2a7/0x316
>> [175827.357035]  [<ffffffff816e747d>] __netif_receive_skb_core+0x569/0x5cb
>> [175827.357045]  [<ffffffffa047d770>] ? br_handle_local_finish+0x41/0x41
>> [bridge]
>> [175827.357051]  [<ffffffff816e7528>] __netif_receive_skb+0x49/0x5b
>> [175827.357058]  [<ffffffff816e76e4>] netif_receive_skb_internal+0x56/0x8d
>> [175827.357066]  [<ffffffffa047d770>] ? br_handle_local_finish+0x41/0x41
>> [bridge]
>> [175827.357073]  [<ffffffff816e7724>] netif_receive_skb+0x9/0xb
>> [175827.357081]  [<ffffffffa047d9e6>] br_handle_frame_finish+0x276/0x2e1
>> [bridge]
>> [175827.357090]  [<ffffffffa04830c7>] br_nf_pre_routing_finish+0x2ad/0x30d
>> [bridge]
>> [175827.357099]  [<ffffffffa047d770>] ? br_handle_local_finish+0x41/0x41
>> [bridge]
>> [175827.357107]  [<ffffffffa048364e>] br_nf_pre_routing+0x527/0x59f [bridge]
>> [175827.357115]  [<ffffffff8170c74f>] nf_iterate+0x3f/0x7a
>> [175827.357122]  [<ffffffff8170c7f8>] nf_hook_slow+0x6e/0x106
>> [175827.357130]  [<ffffffffa047d770>] ? br_handle_local_finish+0x41/0x41
>> [bridge]
>> [175827.357138]  [<ffffffffa047dc35>] br_handle_frame+0x1e4/0x1f9 [bridge]
>> [175827.357145]  [<ffffffffa047da51>] ? br_handle_frame_finish+0x2e1/0x2e1
>> [bridge]
>> [175827.357152]  [<ffffffff816e7328>] __netif_receive_skb_core+0x414/0x5cb
>> [175827.357158]  [<ffffffff816e7528>] __netif_receive_skb+0x49/0x5b
>> [175827.357165]  [<ffffffff816e76e4>] netif_receive_skb_internal+0x56/0x8d
>> [175827.357172]  [<ffffffff816e8664>] napi_gro_receive+0x27/0x68
>> [175827.357179]  [<ffffffffa06134bc>] rtl8169_poll+0x337/0x4d0 [r8169]
>> [175827.357186]  [<ffffffff81087612>] ? notifier_call_chain+0x32/0x5c
>> [175827.357193]  [<ffffffff816e78f0>] net_rx_action+0x6f/0x13e
>> [175827.357198]  [<ffffffff8106fd7b>] __do_softirq+0xc0/0x1c0
>> [175827.357204]  [<ffffffff8106ffe9>] irq_exit+0x38/0x7e
>> [175827.357212]  [<ffffffff81036dab>] do_IRQ+0xb5/0xd0
>> [175827.357221]  [<ffffffff8185baaa>] common_interrupt+0x6a/0x6a
>> [175827.357224]  <EOI>  [<ffffffff81086998>] ?
>> __hrtimer_start_range_ns+0x25f/0x27b
>> [175827.357237]  [<ffffffff8168bbc5>] ? cpuidle_enter_state+0x49/0xac
>> [175827.357243]  [<ffffffff8168bbbe>] ? cpuidle_enter_state+0x42/0xac
>> [175827.357250]  [<ffffffff8168bcf0>] cpuidle_idle_call+0xc8/0x111
>> [175827.357256]  [<ffffffff8103d666>] arch_cpu_idle+0x9/0x18
>> [175827.357262]  [<ffffffff810a83fc>] cpu_startup_entry+0xb5/0x11c
>> [175827.357269]  [<ffffffff8184c287>] rest_init+0x7b/0x7f
>> [175827.357275]  [<ffffffff81c02d04>] start_kernel+0x3b4/0x3c1
>> [175827.357281]  [<ffffffff81c02757>] ? repair_env_string+0x5a/0x5a
>> [175827.357287]  [<ffffffff81c0248b>] x86_64_start_reservations+0x2a/0x2c
>> [175827.357293]  [<ffffffff81c0255a>] x86_64_start_kernel+0xcd/0xd1
>> [175827.357297] ---[ end trace e102d0a9c3759f49 ]---
>> [175827.357336] ------------[ cut here ]------------
>>
>>
>> [175827.357345] WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:153
>> inet_sock_destruct+0x161/0x1af()
>> [175827.357348] Modules linked in: bridge joydev nvidia(PO)
>> x86_pkg_temp_thermal coretemp pcspkr nouveau i2c_i801 snd_hda_codec_realtek
>> snd_hda_codec_hdmi snd_hda_codec_generic mxm_wmi r8169 mii ttm snd_hda_intel
>> snd_hda_codec snd_hwdep rtc_cmos wmi efivarfs xts gf128mul aes_x86_64
>> sha512_generic libiscsi scsi_transport_iscsi tg3 fuse nfs lockd sunrpc jfs
>> hid_sunplus hid_sony hid_samsung hid_pl hid_petalynx hid_monterey hid_microsoft
>> hid_logitech hid_gyration hid_ezkey hid_cypress hid_chicony hid_cherry
>> hid_belkin hid_apple hid_a4tech sl811_hcd aic94xx libsas scsi_transport_sas
>> lpfc qla2xxx scsi_transport_fc megaraid_sas megaraid_mbox megaraid_mm megaraid
>> aacraid sx8 DAC960 cciss 3w_9xxx 3w_xxxx atp870u dc395x qla1280 dmx3191d
>> sym53c8xx gdth advansys initio BusLogic arcmsr aic7xxx aic79xx
>> scsi_transport_spi
>> [175827.357429]  pdc_adma sata_inic162x sata_qstor sata_vsc sata_uli sata_sis
>> sata_sx4 sata_via sata_svw sata_sil24 sata_sil sata_promise pata_sl82c105
>> pata_cs5530 pata_cs5520 pata_via pata_jmicron pata_marvell pata_sis
>> pata_netcell pata_sc1200 pata_pdc202xx_old pata_triflex pata_atiixp pata_opti
>> pata_amd pata_ali pata_it8213 pata_pcmcia pcmcia pcmcia_core pata_ns87415
>> pata_ns87410 pata_serverworks pata_platform pata_artop pata_it821x pata_optidma
>> pata_hpt3x2n pata_hpt3x3 pata_hpt37x pata_hpt366 pata_cmd64x pata_efar
>> pata_rz1000 pata_sil680 pata_radisys pata_pdc2027x pata_mpiix usbhid
>> [175827.357483] CPU: 0 PID: 0 Comm: swapper/0 Tainted: P        W  O
>> 3.14.3-gentoo #1
>> [175827.357486] Hardware name: ASUSTeK COMPUTER INC. G56JR/G56JR, BIOS
>> G56JR.200 01/13/2014
>> [175827.357490]  0000000000000009 ffff88042ee037f8 ffffffff818532e4
>> 0000000000000102
>> [175827.357496]  0000000000000000 ffff88042ee03838 ffffffff8106c79c
>> ffff8803a2560730
>> [175827.357502]  ffffffff8173f483 ffff8803a25606c0 ffff8803a2560838
>> 0000000000000000
>> [175827.357508] Call Trace:
>> [175827.357512]  <IRQ>  [<ffffffff818532e4>] dump_stack+0x4f/0x7c
>> [175827.357522]  [<ffffffff8106c79c>] warn_slowpath_common+0x77/0x91
>> [175827.357529]  [<ffffffff8173f483>] ? inet_sock_destruct+0x161/0x1af
>> [175827.357535]  [<ffffffff8106c7cb>] warn_slowpath_null+0x15/0x17
>> [175827.357541]  [<ffffffff8173f483>] inet_sock_destruct+0x161/0x1af
>> [175827.357548]  [<ffffffff816d86cb>] __sk_free+0x18/0x10c
>> [175827.357553]  [<ffffffff816d881c>] sk_free+0x13/0x15
>> [175827.357560]  [<ffffffff8172f1ff>] tcp_v4_rcv+0x6dd/0x734
>> [175827.357567]  [<ffffffff81087612>] ? notifier_call_chain+0x32/0x5c
>> [175827.357575]  [<ffffffffa0616009>] ? rtl8169_start_xmit+0x29a/0x716 [r8169]
>> [175827.357581]  [<ffffffff810911ad>] ? update_curr+0x89/0xe1
>> [175827.357587]  [<ffffffff81711b82>] ip_local_deliver_finish+0x10c/0x1ed
>> [175827.357593]  [<ffffffff81711d9d>] ip_local_deliver+0x47/0x78
>> [175827.357599]  [<ffffffff81711a3f>] ip_rcv_finish+0x29e/0x2d5
>> [175827.357605]  [<ffffffff81712075>] ip_rcv+0x2a7/0x316
>> [175827.357612]  [<ffffffff816e747d>] __netif_receive_skb_core+0x569/0x5cb
>> [175827.357620]  [<ffffffffa047d770>] ? br_handle_local_finish+0x41/0x41
>> [bridge]
>> [175827.357626]  [<ffffffff816e7528>] __netif_receive_skb+0x49/0x5b
>> [175827.357632]  [<ffffffff816e76e4>] netif_receive_skb_internal+0x56/0x8d
>> [175827.357640]  [<ffffffffa047d770>] ? br_handle_local_finish+0x41/0x41
>> [bridge]
>> [175827.357646]  [<ffffffff816e7724>] netif_receive_skb+0x9/0xb
>> [175827.357653]  [<ffffffffa047d9e6>] br_handle_frame_finish+0x276/0x2e1
>> [bridge]
>> [175827.357661]  [<ffffffffa04830c7>] br_nf_pre_routing_finish+0x2ad/0x30d
>> [bridge]
>> [175827.357669]  [<ffffffffa047d770>] ? br_handle_local_finish+0x41/0x41
>> [bridge]
>> [175827.357677]  [<ffffffffa048364e>] br_nf_pre_routing+0x527/0x59f [bridge]
>> [175827.357684]  [<ffffffff8170c74f>] nf_iterate+0x3f/0x7a
>> [175827.357691]  [<ffffffff8170c7f8>] nf_hook_slow+0x6e/0x106
>> [175827.357699]  [<ffffffffa047d770>] ? br_handle_local_finish+0x41/0x41
>> [bridge]
>> [175827.357707]  [<ffffffffa047dc35>] br_handle_frame+0x1e4/0x1f9 [bridge]
>> [175827.357714]  [<ffffffffa047da51>] ? br_handle_frame_finish+0x2e1/0x2e1
>> [bridge]
>> [175827.357720]  [<ffffffff816e7328>] __netif_receive_skb_core+0x414/0x5cb
>> [175827.357727]  [<ffffffff816e7528>] __netif_receive_skb+0x49/0x5b
>> [175827.357733]  [<ffffffff816e76e4>] netif_receive_skb_internal+0x56/0x8d
>> [175827.357740]  [<ffffffff816e8664>] napi_gro_receive+0x27/0x68
>> [175827.357747]  [<ffffffffa06134bc>] rtl8169_poll+0x337/0x4d0 [r8169]
>> [175827.357754]  [<ffffffff81087612>] ? notifier_call_chain+0x32/0x5c
>> [175827.357761]  [<ffffffff816e78f0>] net_rx_action+0x6f/0x13e
>> [175827.357766]  [<ffffffff8106fd7b>] __do_softirq+0xc0/0x1c0
>> [175827.357772]  [<ffffffff8106ffe9>] irq_exit+0x38/0x7e
>> [175827.357778]  [<ffffffff81036dab>] do_IRQ+0xb5/0xd0
>> [175827.357785]  [<ffffffff8185baaa>] common_interrupt+0x6a/0x6a
>> [175827.357788]  <EOI>  [<ffffffff81086998>] ?
>> __hrtimer_start_range_ns+0x25f/0x27b
>> [175827.357800]  [<ffffffff8168bbc5>] ? cpuidle_enter_state+0x49/0xac
>> [175827.357807]  [<ffffffff8168bbbe>] ? cpuidle_enter_state+0x42/0xac
>> [175827.357813]  [<ffffffff8168bcf0>] cpuidle_idle_call+0xc8/0x111
>> [175827.357819]  [<ffffffff8103d666>] arch_cpu_idle+0x9/0x18
>> [175827.357824]  [<ffffffff810a83fc>] cpu_startup_entry+0xb5/0x11c
>> [175827.357830]  [<ffffffff8184c287>] rest_init+0x7b/0x7f
>> [175827.357836]  [<ffffffff81c02d04>] start_kernel+0x3b4/0x3c1
>> [175827.357842]  [<ffffffff81c02757>] ? repair_env_string+0x5a/0x5a
>> [175827.357848]  [<ffffffff81c0248b>] x86_64_start_reservations+0x2a/0x2c
>> [175827.357854]  [<ffffffff81c0255a>] x86_64_start_kernel+0xcd/0xd1
>> [175827.357858] ---[ end trace e102d0a9c3759f4a ]---
>>
>> and out of memory message:
>> [183972.519743] TCP: out of memory -- consider tuning tcp_mem
>>
>> tcp_mem and sockstat:
>>
>>  # cat /proc/sys/net/ipv4/tcp_mem ; cat /proc/net/sockstat
>> 376935  502581  753870
>> sockets: used 467
>> TCP: inuse 3 orphan 0 tw 0 alloc 5 mem 753741
>> UDP: inuse 1 mem 1
>> UDPLITE: inuse 0
>> RAW: inuse 0
>> FRAG: inuse 0 memory 0
>>
>> After exiting rtorrent stats above didn't change.
>>
>>  # free -m
>>              total       used       free     shared    buffers     cached
>> Mem:         15908       9873       6035          3         50       8890
>> -/+ buffers/cache:        932      14976
>> Swap:         8175          1       8174
>>
>>  # sysctl net.ipv4.ip_forward
>> net.ipv4.ip_forward = 1
>>
>>  # uptime
>>  00:40:06 up 2 days,  4:45,  8 users,  load average: 0,01, 0,15, 0,33
>>
>> Hardware:
>>   Network controller: Intel Corporation Wireless 7260 (rev 73)
>>   Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI
>> Express Gigabit Ethernet Controller (rev 0c)
>
> Hmm...
>
> This looks pretty bad. Have you tried a more recent kernel ?
>
> (v3.14.6 or v3.15)
>
>
>
