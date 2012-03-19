From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Mon, 19 Mar 2012 07:43:34 -0700
Message-ID: <4F674616.8080103@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com> <4F579A88.6030503@openwrt.org> <4F61F551.5010608@gmail.com> <4F639851.5080500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>,
	Mohammed Shafi <shafi.wireless@gmail.com>,
	linux-kernel@vger.kernel.org, Linux-netdev <netdev@vger.kernel.org>
To: Linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36827 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626Ab2CSOnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 10:43:42 -0400
In-Reply-To: <4F639851.5080500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2012 12:45 PM, Justin P. Mattock wrote:
> On 03/15/2012 06:57 AM, Justin P. Mattock wrote:
>>
>>>> ok! I have set that on the machine.. will see if I get this message in
>>>> the upcoming weeks.
>>> Also, please try this patch with powersave enabled:
>>> http://nbd.name/ps-fix.patch
>>>
>>> - Felix
>>>
>>
>> I did have ps-fix patch running, but removed it in the kernel due to not
>> being able to connect once I wakeup from suspend. anyway I have enable
>> debugging for the wireless(hopefully) and was able to trigger this after
>> a fresh build of the kernel last night(git clean -fx and all)
>>
>> the message I have in dmesg is:
>>
>> [ 3348.274932] ath: Failed to stop TX DMA, queues=0x004!
>> [ 3348.292637] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
>> [ 3348.292643] ath: Could not stop RX, we could be confusing the DMA
>> engine when we start RX up
>> [ 3348.292648] ------------[ cut here ]------------
>> [ 3348.292662] WARNING: at drivers/net/wireless/ath/ath9k/recv.c:537
>> ath_stoprecv+0xed/0x100 [ath9k]()
>> [ 3348.292666] Hardware name: 0914
>> [ 3348.292669] Modules linked in: dm_crypt ipt_REJECT ipt_LOG xt_limit
>> xt_tcpudp xt_addrtype joydev xt_state arc4 snd_hda_codec_hdmi
>> snd_hda_codec_conexant ath9k snd_hda_intel snd_hda_codec snd_hwdep
>> mac80211 snd_pcm snd_seq_midi nf_conntrack_netbios_ns
>> nf_conntrack_broadcast nf_nat_ftp nf_nat snd_rawmidi ath9k_common
>> nf_conntrack_ipv4 uvcvideo nf_defrag_ipv4 ath9k_hw snd_seq_midi_event
>> nf_conntrack_ftp nf_conntrack snd_seq snd_timer snd_seq_device ath
>> videobuf2_core videodev cfg80211 psmouse iptable_filter ip_tables
>> videobuf2_vmalloc videobuf2_memops name_laptop intel_ips sparse_keymap
>> serio_raw snd lp parport x_tables soundcore snd_page_alloc i915
>> drm_kms_helper drm i2c_algo_bit intel_agp intel_gtt usb_storage agpgart
>> video r8169 uas
>> [ 3348.292786] Pid: 5972, comm: kworker/u:24 Not tainted
>> 3.3.0-rc7-00048-g762ad8a #1
>> [ 3348.292790] Call Trace:
>> [ 3348.292804] [<c1046f32>] warn_slowpath_common+0x72/0xa0
>> [ 3348.292816] [<f8f528bd>] ? ath_stoprecv+0xed/0x100 [ath9k]
>> [ 3348.292826] [<f8f528bd>] ? ath_stoprecv+0xed/0x100 [ath9k]
>> [ 3348.292832] [<c1046f82>] warn_slowpath_null+0x22/0x30
>> [ 3348.292842] [<f8f528bd>] ath_stoprecv+0xed/0x100 [ath9k]
>> [ 3348.292855] [<f8f4e35d>] ath_prepare_reset+0x5d/0xd0 [ath9k]
>> [ 3348.292865] [<f8f4f92c>] ath_reset_internal+0x7c/0x160 [ath9k]
>> [ 3348.292875] [<c10a862b>] ? trace_hardirqs_on+0xb/0x10
>> [ 3348.292885] [<f8f4fa35>] ath_reset+0x25/0xb0 [ath9k]
>> [ 3348.292891] [<c10a8594>] ? trace_hardirqs_on_caller+0xf4/0x180
>> [ 3348.292901] [<f8f51377>] ath_reset_work+0x17/0x20 [ath9k]
>> [ 3348.292909] [<c10663d6>] process_one_work+0x166/0x5b0
>> [ 3348.292916] [<c1066362>] ? process_one_work+0xf2/0x5b0
>> [ 3348.292924] [<c12ca72b>] ? do_raw_spin_lock+0x3b/0xf0
>> [ 3348.292935] [<f8f51360>] ? ath_isr+0x270/0x270 [ath9k]
>> [ 3348.292944] [<c1066b34>] worker_thread+0x124/0x2c0
>> [ 3348.292950] [<c1066a10>] ? rescuer_thread+0x1c0/0x1c0
>> [ 3348.292957] [<c106b77d>] kthread+0x7d/0x90
>> [ 3348.292963] [<c106b700>] ? __init_kthread_worker+0x60/0x60
>> [ 3348.292972] [<c158ed42>] kernel_thread_helper+0x6/0x10
>> [ 3348.292976] ---[ end trace ced0f48896d487b2 ]---
>> [ 3349.735411] ath: Failed to stop TX DMA, queues=0x005!
>> [ 3349.753028] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
>> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
>> [ 3349.753034] ath: Could not stop RX, we could be confusing the DMA
>> engine when we start RX up
>>
>>
>> full dmesg is here;
>> http://fpaste.org/YhqT/
>>
>> hope this helps with finding the bug!
>>
>> Justin P. Mattock
>
> not sure if this is correct, but from what I remember, not cleaning the
> directory of the kernel seems to hide this bug, doing a git clean -fx
> has triggered this twice now, as opposed to waiting a week.. anyway I
> added more debug options to the kernel to see what it might produce when
> this is triggered. this is what i have now..:
>
>
> [10558.732792] TKIP decrypt: data(len=1468) 08 28 08 20 00 00 00 00 aa
> aa 03 00 00 00 08 00 45 00 05 a8 54 36 40 00 3a 06 6a 5d cc 02 a6 81 0a
> 00 00 39 00 50 9f 02 8c ff aa e2 22 c1 69 aa 80 10 10 f8 1d 52 00 00 01
> 01 08 0a 0d 20 6d 44 00 27 3b 4d c1 08 29 9c c6 b1 d3 18 22 9e 13 08 a5
> dd ac 66 24 3a 18 22 11 84 ac 6a 49 94 c4 84 fb 73 86 94 10 9e 72 e9 04
> 51 04 d2 93 d3 2e a3 28 51 4c b4 8c 89 27 4c bd 3e 8c 60 44 10 2a 91 32
> e9 da 25 84 08 81 49 45 47 0e cc e0 8a 00 25 34 26 5d 7e 5c 47 e0 85 10
> 9e 03 c8 9c 57 fe 4f 4c c6 50 44 46 09 e0 74 23 0b 10 00 13 ef 12 3d 12
> 82 21 18 0f 22 47 12 64 25 e9 96 30 44 23 03 b9 10 c4 63 8c cf b3 38 6b
> 98 14 16 a5 12 27 d3 db 02 20 52 41 3d 92 9e 03 38 51 4e 05 0d 3d a0 fe
> 08 22 8c 25 20 9c 44 bd b8 41 14 40 a1 23 2c 06 70 45 38 14 06 a3 98 97
> 5c a0 4a 09 19 1f 7a 5e d1 9c 28 84 c3 49 42 58 ce 72 f5 fa 7d 30 44 23
> 09 e4 49 53 96 03 0c 25 28 69 42 29 aa d5 99 18 9e 9d 61 45 38 14 81 5c
> f2 eb 39 67 0d 28 14 e2 48 c3 db 02 64 10 84 ba 4b d7 02 20 51 4c c0 9e
> 42 04 10 42 72 54 0e 7e 88 e5 c5 0d 69 37 27 24 28 93 21 1c c5 3c 27 91
> 05 1e d0 41 ed 8e 81 48 85 6c f9 74 6d b5 d4 de 90 65 de 69 a6 c3 10 74
> 4d 73 f4 4a 72 f6 c6 35 67 ee 75 2f 41 4c d8 53 03 fe 47 dc 16 9f 3d ad
> 6a a1 db 64 ac 68 fc fe a6 c4 a7 30 94 49 5d b9 18 96 82 f3 d0 aa 57 64
> e9 50 39 04 a4 4e 53 fc 71 82 5c 62 57 d4 98 c6 e1 11 01 09 7a 23 98 95
> 26 10 81 06 63 4a 4a dc 24 04 21 22 65 44 99 00 07 69 30 07 11 72 4e 63
> 4d a4 05 66 5c f8 9b 6b ed 1b 15 be b3 7c 57 5c 9d bb 5d 4a 91 4b 65 b0
> 32 cb 8f 05 a4 05 29 33 75 2a 0e 68 04 6b 20 a7 1c a7 9c 5c 95 21 cf ca
> bc ad 4f ac 86 98 4b 68 87 3e 5f 72 e5 6e 9d 8b b6 2d 9b 0e 9f 71 5b ab
> 2b aa 1f ab ba 0b 78 a4 ad 61 14 ab a6 4f 86 71 e2 87 5a 91 58 74 68 9e
> ad 5a 4a 48 90 eb 1c 3e 49 6c 6d b9 5b a3 f5 31 3a 6b 58 5a 00 20 c3 a6
> fc d6 67 50 93 22 7d 99 f6 45 58 af 43 00 9c 94 80 71 18 fe 48 71 29 16
> 8e 44 48 c2 52 04 41 14 83 42 b3 78 a7 89 f6 6e f7 a1 79 0a b9 5c a9 ee
> 74 68 6d 75 c8 4a 18 4b 00 be a7 83 7d d9 29 52 95 ee b4 75 4f ac 4c d6
> 44 46 2b 06 b3 d4 26 53 cc c2 1a d8 75 aa f6 f6 9b 20 ae d5 65 f1 a6 d6
> a4 21 54 cf 5c 5a 4b 4e ba 0a 41 2a 09 4f bb a7 51 c0 88 26 cb 32 cc 15
> ef 4f ab 15 4c c5 0b 41 5a 3a 42 44 d3 9f 5e 91 09 71 39 56 80 63 40 80
> 02 08 89 6a 9a 46 13 cb d1 04 4a eb 08 37 a6 fb b8 4f 0f c5 04 4a 30 0e
> 45 2a e3 4d ad b5 f7 2d f9 16 8b c5 5d 6d 25 4d 61 4b 76 ef 06 86 96 8d
> 49 43 ab 74 ba 56 09 48 92 40 4c 86 71 24 b6 e2 ca b3 7d 42 a1 d2 1a 1c
> d6 82 23 6a d9 e4 bd 9d b6 76 bd d5 cb 45 ad fb 85 65 6d 39 42 ab 5f a9
> 69 1e 19 b4 ba 84 ad 21 2e 36 94 cd 7e f6 51 23 e4 90 dc 51 b1 52 a1 f5
> 3d bc dc 0e 68 06 19 14 45 23 51 13 00 7a fd 18 e3 15 e2 b7 8b 44 11 28
> 46 a9 80 31 12 20 f4 9c 04 94 83 40 c8 92 90 24 41 12 ea 65 04 4a e8 00
> a7 5b 47 8a a8 6a b6 75 56 f5 dd 77 07 2d 3b 69 84 a9 6c a6 95 b4 ae a5
> f4 a5 5d de a9 ac 29 28 d6 b9 25 03 49 2a cf 01 29 cf 2a 5b 9c 60 b0 ab
> fd 4d b2 1d 85 ad 05 c2 f8 dc b2 db b6 16 c0 ba d9 af 97 6a 1a 8b e5 20
> b4 5a ea ee 0c 5b 6e b4 ac d3 be ff 00 70 8d 69 74 38 90 50 eb 22 52 50
> 40 49 9a 93 88 eb 33 a9 88 30 8a cf 97 eb a6 11 2c 02 db 6c c9 df c9 6a
> af 34 04 e6 31 94 c0 22 71 46 25 7a fc 2d 39 12 f7 49 38 65 99 eb f2 c3
> c4 50 58 d3 78 09 69 4c 89 90 9e 32 10 62 3c a8 32 da 4d a0 29 67 17 ed
> 4d af ba 37 18 b2 5d ab 2a e9 2a ab 24 9b 6f 83 6d a2 da 8b 4d bc f3 bd
> ea 9c 4a 8a 7d c4 0d 32 19 ce 24 60 c5 64 56 67 a8 ce 75 3b 43 da d6 9c
> 87 e0 bb f5 7c 63 b2 93 c9 ed ec 5a 4a ab d5 55 43 28 52 ae 4f 34 c5 3a
> 92 d1 71 0c 38 d2 b5 e9 09 0d 25 0e 28 b8 48 9c e4 04 e2 63 26 00 18 de
> b2 99 ea ee 73 5c ec 2d 8b 61 90 c3 a3 a6 d1 67 24 54 6b 7b 59 b8 fa dc
> f3 b4 bb 5e be be f0 f5 2b dd d5 65 6a da 6c d0 a6 49 24 84 3c da 52 14
> ad 52 1d 9d 90 e6 c9 7b 5b 88 95 2f a7 7a 9b 67 cd c0 5a d1 1e 41 94 28
> c9 50 19 65 2e 9e d8 a7 15 e9 c3 42 1a 40 90 e8 7a f4 94 30 e2 12 2c 69
> bc 04 56 90 72 cb af 66 38 c2 89 40 68 e4 4d d2 99 e5 81 fb fe 88 22 ba
> c2 10 29 44 86 19 e5 86 7d 21 e2 3c ab 91 2d bc 81 00 10 44 b3 90 eb db
> 0b 11 be 29 e0 6c 21 01 04 a4 08 00 1c 4e 1e a9 99 08 22 53 c2 39 14 bf
> 8c f6 7e d8 dc f7 63 6a b9 56 56 d3 5c 1f 27 c2 0a 54 34 59 29 6d b5 2d
> 5a d4 b0 a2 14 74 99 44 ac 6e 28 da b1 fd 46 ad f4 f0 2d 6b 48 2b ae be
> 3b d8 83 90 53 b5 3c 75 de 53 14 cb ab ee 59 d0 6b 1c 09 71 28 0b d3 22
> 80 da bd ec 27 38 98 c9 22 06 37 ac c6 7a c3 de c7 41 ad 8b 79 8c 20 b9
> bc 9d b2 b6 ce d6 ac 16 cb 6b d7 1a bb 8b 5d db 95 6e 54 34 df 85 6d a7
> 52 ad 3f 9c 42 53 ef 95 01 81 e9 1c ba 49 0d 72 9f 8f ed
> [10558.734622] TKIP decrypt: iv16=0808 iv32=00000000
> [10560.232164] wlan0: detected beacon loss from AP - sending probe request
> [10560.645078] ath: Failed to stop TX DMA, queues=0x005!
> [10560.662741] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
> [10560.662750] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10560.662754] ------------[ cut here ]------------
> [10560.662770] WARNING: at drivers/net/wireless/ath/ath9k/recv.c:537
> ath_stoprecv+0xed/0x100 [ath9k]()
> [10560.662775] Hardware name: 0914
> [10560.662778] Modules linked in: dm_crypt ipt_REJECT ipt_LOG joydev
> xt_limit xt_tcpudp xt_addrtype xt_state arc4 ath9k mac80211
> snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_intel snd_hda_codec
> snd_hwdep ath9k_common ath9k_hw nf_conntrack_netbios_ns
> nf_conntrack_broadcast snd_pcm snd_seq_midi snd_rawmidi nf_nat_ftp
> nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 snd_seq_midi_event
> nf_conntrack_ftp psmouse uvcvideo lp snd_seq videobuf2_core nf_conntrack
> ath videodev serio_raw ideapad_laptop sparse_keymap parport intel_ips
> cfg80211 videobuf2_vmalloc videobuf2_memops snd_timer snd_seq_device snd
> iptable_filter ip_tables x_tables soundcore snd_page_alloc usb_storage
> uas i915 drm_kms_helper drm intel_agp r8169 i2c_algo_bit intel_gtt
> agpgart video
> [10560.662895] Pid: 10046, comm: kworker/u:20 Not tainted
> 3.3.0-rc7-00103-g0c4d067 #1
> [10560.662899] Call Trace:
> [10560.662914] [<c1047572>] warn_slowpath_common+0x72/0xa0
> [10560.662925] [<f8c08bdd>] ? ath_stoprecv+0xed/0x100 [ath9k]
> [10560.662935] [<f8c08bdd>] ? ath_stoprecv+0xed/0x100 [ath9k]
> [10560.662942] [<c10475c2>] warn_slowpath_null+0x22/0x30
> [10560.662952] [<f8c08bdd>] ath_stoprecv+0xed/0x100 [ath9k]
> [10560.662965] [<f8c0452d>] ath_prepare_reset+0x5d/0xd0 [ath9k]
> [10560.662975] [<f8c05adc>] ath_reset_internal+0x7c/0x160 [ath9k]
> [10560.662984] [<c10a8cab>] ? trace_hardirqs_on+0xb/0x10
> [10560.662994] [<f8c05be5>] ath_reset+0x25/0xb0 [ath9k]
> [10560.663000] [<c10a8c14>] ? trace_hardirqs_on_caller+0xf4/0x180
> [10560.663011] [<f8c07527>] ath_reset_work+0x17/0x20 [ath9k]
> [10560.663020] [<c10669d8>] process_one_work+0x168/0x5c0
> [10560.663027] [<c1066964>] ? process_one_work+0xf4/0x5c0
> [10560.663035] [<c12cc55b>] ? do_raw_spin_lock+0x3b/0xf0
> [10560.663045] [<f8c07510>] ? ath_isr+0x270/0x270 [ath9k]
> [10560.663054] [<c1067141>] worker_thread+0x121/0x2c0
> [10560.663061] [<c1067020>] ? rescuer_thread+0x1c0/0x1c0
> [10560.663067] [<c106be5d>] kthread+0x7d/0x90
> [10560.663073] [<c106bde0>] ? __init_kthread_worker+0x60/0x60
> [10560.663083] [<c15a1102>] kernel_thread_helper+0x6/0x10
> [10560.663087] ---[ end trace 7fd01c4e029fbbc7 ]---
> [10560.670137] ieee80211 phy0: wlan0: No ack for nullfunc frame to AP
> 00:1e:2a:62:6b:1e, try 1/2
> [10561.166344] ieee80211 phy0: wlan0: Failed to send nullfunc to AP
> 00:1e:2a:62:6b:1e after 500ms, disconnecting.
> [10561.168266] wlan0: moving STA 00:1e:2a:62:6b:1e to state 2
> [10561.168272] wlan0: moving STA 00:1e:2a:62:6b:1e to state 1
> [10561.168277] wlan0: moving STA 00:1e:2a:62:6b:1e to state 0
> [10561.174026] ieee80211 phy0: Removed STA 00:1e:2a:62:6b:1e
> [10561.174390] ieee80211 phy0: Destroyed STA 00:1e:2a:62:6b:1e
> [10561.175170] ieee80211 phy0: device now idle
> [10561.175231] cfg80211: All devices are disconnected, going to restore
> regulatory settings
> [10561.175271] cfg80211: Restoring regulatory settings
> [10561.175292] cfg80211: Calling CRDA to update world regulatory domain
> [10561.185363] cfg80211: Ignoring regulatory request Set by core since
> the driver uses its own custom regulatory domain
> [10561.185415] cfg80211: World regulatory domain updated:
> [10561.185419] cfg80211: (start_freq - end_freq @ bandwidth),
> (max_antenna_gain, max_eirp)
> [10561.185424] cfg80211: (2402000 KHz - 2472000 KHz @ 40000 KHz), (300
> mBi, 2000 mBm)
> [10561.185429] cfg80211: (2457000 KHz - 2482000 KHz @ 20000 KHz), (300
> mBi, 2000 mBm)
> [10561.185434] cfg80211: (2474000 KHz - 2494000 KHz @ 20000 KHz), (300
> mBi, 2000 mBm)
> [10561.185439] cfg80211: (5170000 KHz - 5250000 KHz @ 40000 KHz), (300
> mBi, 2000 mBm)
> [10561.185444] cfg80211: (5735000 KHz - 5835000 KHz @ 40000 KHz), (300
> mBi, 2000 mBm)
> [10561.578320] ieee80211 phy0: device no longer idle - scanning
> [10561.603489] ath: Failed to stop TX DMA, queues=0x005!
> [10561.621059] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
> [10561.621067] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10561.694090] ath: Failed to stop TX DMA, queues=0x001!
> [10561.711600] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
> [10561.711608] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10561.785820] ath: Failed to stop TX DMA, queues=0x001!
> [10561.803374] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
> [10561.803382] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10561.877450] ath: Failed to stop TX DMA, queues=0x001!
> [10561.894814] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
> [10561.894821] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10561.969359] ath: Failed to stop TX DMA, queues=0x001!
> [10561.986773] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
> [10561.986777] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10562.061391] ath: Failed to stop TX DMA, queues=0x001!
> [10562.078921] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
> [10562.078928] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10562.153191] ath: Failed to stop TX DMA, queues=0x001!
> [10562.170828] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
> [10562.170835] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10562.244937] ath: Failed to stop TX DMA, queues=0x001!
> [10562.262556] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
> [10562.262563] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10562.336708] ath: Failed to stop TX DMA, queues=0x001!
> [10562.354225] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
> [10562.354232] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10562.428559] ath: Failed to stop TX DMA, queues=0x001!
> [10562.446067] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
> [10562.446075] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10562.520388] ath: Failed to stop TX DMA, queues=0x001!
> [10562.537981] ath: DMA failed to stop in 10 ms AR_CR=0x00000024
> AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
> [10562.537987] ath: Could not stop RX, we could be confusing the DMA
> engine when we start RX up
> [10562.612159] ath: Failed to stop TX DMA, queues=0x001!
>
>
>
> hope this helps.
>
> Justin P. Mattock
>

seems I got this when waking up from suspend, was trying to connect with 
NM then all of a sudden Xorg shut off and this appeared on the 
screen(image links below I could not save dmesg only pic)
http://flic.kr/p/bEhf2K
http://flic.kr/p/bEhf2x
http://flic.kr/p/bEhf2n
http://flic.kr/p/bEhf26

I see ath9k in the image, but am unsure if its related.
kernel is: 3.3.0-rc7-next-20120316

Justin P. Mattock
