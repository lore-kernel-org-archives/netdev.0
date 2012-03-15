From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020
 DMADBG_7=0x00008040
Date: Thu, 15 Mar 2012 06:57:37 -0700
Message-ID: <4F61F551.5010608@gmail.com>
References: <4F576FD5.2050208@gmail.com> <CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com> <4F577D9B.7020402@gmail.com> <4F579A88.6030503@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mohammed Shafi <shafi.wireless@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>,
	Linux-wireless <linux-wireless@vger.kernel.org>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F579A88.6030503@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> ok! I have set that on the machine.. will see if I get this message in
>> the upcoming weeks.
> Also, please try this patch with powersave enabled:
> http://nbd.name/ps-fix.patch
>
> - Felix
>

I did have ps-fix patch running, but removed it in the kernel due to not 
being able to connect once I wakeup from suspend. anyway I have enable 
debugging for the wireless(hopefully) and was able to trigger this after 
a fresh build of the kernel last night(git clean -fx and all)

the message I have in dmesg is:

[ 3348.274932] ath: Failed to stop TX DMA, queues=0x004!
[ 3348.292637] ath: DMA failed to stop in 10 ms AR_CR=0x00000024 
AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
[ 3348.292643] ath: Could not stop RX, we could be confusing the DMA 
engine when we start RX up
[ 3348.292648] ------------[ cut here ]------------
[ 3348.292662] WARNING: at drivers/net/wireless/ath/ath9k/recv.c:537 
ath_stoprecv+0xed/0x100 [ath9k]()
[ 3348.292666] Hardware name: 0914
[ 3348.292669] Modules linked in: dm_crypt ipt_REJECT ipt_LOG xt_limit 
xt_tcpudp xt_addrtype joydev xt_state arc4 snd_hda_codec_hdmi 
snd_hda_codec_conexant ath9k snd_hda_intel snd_hda_codec snd_hwdep 
mac80211 snd_pcm snd_seq_midi nf_conntrack_netbios_ns 
nf_conntrack_broadcast nf_nat_ftp nf_nat snd_rawmidi ath9k_common 
nf_conntrack_ipv4 uvcvideo nf_defrag_ipv4 ath9k_hw snd_seq_midi_event 
nf_conntrack_ftp nf_conntrack snd_seq snd_timer snd_seq_device ath 
videobuf2_core videodev cfg80211 psmouse iptable_filter ip_tables 
videobuf2_vmalloc videobuf2_memops name_laptop intel_ips sparse_keymap 
serio_raw snd lp parport x_tables soundcore snd_page_alloc i915 
drm_kms_helper drm i2c_algo_bit intel_agp intel_gtt usb_storage agpgart 
video r8169 uas
[ 3348.292786] Pid: 5972, comm: kworker/u:24 Not tainted 
3.3.0-rc7-00048-g762ad8a #1
[ 3348.292790] Call Trace:
[ 3348.292804]  [<c1046f32>] warn_slowpath_common+0x72/0xa0
[ 3348.292816]  [<f8f528bd>] ? ath_stoprecv+0xed/0x100 [ath9k]
[ 3348.292826]  [<f8f528bd>] ? ath_stoprecv+0xed/0x100 [ath9k]
[ 3348.292832]  [<c1046f82>] warn_slowpath_null+0x22/0x30
[ 3348.292842]  [<f8f528bd>] ath_stoprecv+0xed/0x100 [ath9k]
[ 3348.292855]  [<f8f4e35d>] ath_prepare_reset+0x5d/0xd0 [ath9k]
[ 3348.292865]  [<f8f4f92c>] ath_reset_internal+0x7c/0x160 [ath9k]
[ 3348.292875]  [<c10a862b>] ? trace_hardirqs_on+0xb/0x10
[ 3348.292885]  [<f8f4fa35>] ath_reset+0x25/0xb0 [ath9k]
[ 3348.292891]  [<c10a8594>] ? trace_hardirqs_on_caller+0xf4/0x180
[ 3348.292901]  [<f8f51377>] ath_reset_work+0x17/0x20 [ath9k]
[ 3348.292909]  [<c10663d6>] process_one_work+0x166/0x5b0
[ 3348.292916]  [<c1066362>] ? process_one_work+0xf2/0x5b0
[ 3348.292924]  [<c12ca72b>] ? do_raw_spin_lock+0x3b/0xf0
[ 3348.292935]  [<f8f51360>] ? ath_isr+0x270/0x270 [ath9k]
[ 3348.292944]  [<c1066b34>] worker_thread+0x124/0x2c0
[ 3348.292950]  [<c1066a10>] ? rescuer_thread+0x1c0/0x1c0
[ 3348.292957]  [<c106b77d>] kthread+0x7d/0x90
[ 3348.292963]  [<c106b700>] ? __init_kthread_worker+0x60/0x60
[ 3348.292972]  [<c158ed42>] kernel_thread_helper+0x6/0x10
[ 3348.292976] ---[ end trace ced0f48896d487b2 ]---
[ 3349.735411] ath: Failed to stop TX DMA, queues=0x005!
[ 3349.753028] ath: DMA failed to stop in 10 ms AR_CR=0x00000024 
AR_DIAG_SW=0x02000020 DMADBG_7=0x00006040
[ 3349.753034] ath: Could not stop RX, we could be confusing the DMA 
engine when we start RX up


full dmesg is here;
http://fpaste.org/YhqT/

hope this helps with finding the bug!

Justin P. Mattock
