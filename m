From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: tun oops dereferencing garbage nsproxy-> address.
Date: Sun, 18 Mar 2012 21:02:15 +0100
Message-ID: <201203182102.15877.maciej.rutecki@gmail.com>
References: <20120313034201.GA13156@redhat.com>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>, serue@us.ibm.com,
	ebiederm@xmission.com
To: Dave Jones <davej@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120313034201.GA13156@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On wtorek, 13 marca 2012 o 04:42:02 Dave Jones wrote:
> BUG: unable to handle kernel paging request at 0000000100000029
> IP: [<ffffffffa06ec54f>] tun_chr_open+0x4f/0x80 [tun]
> PGD 5ae4f067 PUD 0
> Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> CPU 1
> Modules linked in: tun binfmt_misc can_bcm cmtp kernelcapi nfnetlink bnep
> can_raw af_802154 phonet bluetooth can pppoe pppox ppp_generic slhc irda
> crc_ccitt rds af_key rose ax25 appletalk atm ipx p8022 psnap llc p8023
> tcp_lp iwlwifi mac80211 cfg80211 nfs fscache auth_rpcgss nfs_acl fuse
> lockd ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter
> ip6_tables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xts
> gf128mul dm_crypt dm_mirror dm_region_hash dm_log arc4 snd_hda_codec_hdmi
> uvcvideo snd_hda_codec_idt videobuf2_core snd_usb_audio snd_hda_intel
> videodev snd_hda_codec dell_wmi sparse_keymap media snd_usbmidi_lib
> snd_hwdep v4l2_compat_ioctl32 snd_rawmidi cdc_ether videobuf2_vmalloc
> videobuf2_memops snd_seq usbnet cdc_wdm mii cdc_acm snd_seq_device snd_pcm
> dell_laptop dcdbas joydev microcode snd_timer tg3 snd pcspkr i2c_i801
> iTCO_wdt iTCO_vendor_support soundcore snd_page_alloc rfkill wmi sunrpc
> i915 drm_kms_helper drm i2c_algo_bit i2c_core video [last unloaded:
> cfg80211]
> 
> Pid: 15413, comm: trinity Not tainted 3.3.0-rc7+ #54 Dell Inc. Adamo 13  
> /0N70T0 RIP: 0010:[<ffffffffa06ec54f>]  [<ffffffffa06ec54f>]
> tun_chr_open+0x4f/0x80 [tun] RSP: 0018:ffff8800a5e29bc8  EFLAGS: 00010286
> RAX: ffff88012036fd88 RBX: ffff8801084c4dc0 RCX: 0000000000000006
> RDX: 0000000100000001 RSI: ffff88000fd9abc8 RDI: 0000000000000292
> RBP: ffff8800a5e29bd8 R08: 0000000000000000 R09: 0000000000000001
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801084c4dc0
> R13: ffff88012eb10d20 R14: ffffffffa06f0000 R15: ffffffff81856ae0
> FS:  00007f3ebcb1a700(0000) GS:ffff88013b400000(0000)
> knlGS:0000000000000000 CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000100000029 CR3: 00000000032bb000 CR4: 00000000000406e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process trinity (pid: 15413, threadinfo ffff8800a5e28000, task
> ffff88000fd9a4a0) Stack:
>  00000000000000c8 0000000000000000 ffff8800a5e29c38 ffffffff813fcf38
>  ffffffff81c54838 0000000000000001 ffff8800a5e29c18 ffffffff816a1afd
>  ffff8801084c4dc0 ffff8801396bbab8 ffff88012eb10d20 0000000000000000
> Call Trace:
>  [<ffffffff813fcf38>] misc_open+0x1d8/0x670
>  [<ffffffff816a1afd>] ? sub_preempt_count+0x9d/0xd0
>  [<ffffffff811c2978>] chrdev_open+0x258/0x350
>  [<ffffffff811baa04>] __dentry_open+0x384/0x550
>  [<ffffffff816a1afd>] ? sub_preempt_count+0x9d/0xd0
>  [<ffffffff811c2720>] ? cdev_put+0x30/0x30
>  [<ffffffff811bc224>] nameidata_to_filp+0x74/0x80
>  [<ffffffff811ce59c>] do_last+0x26c/0x930
>  [<ffffffff811ced76>] path_openat+0xd6/0x3e0
>  [<ffffffff810a6298>] ? sched_clock_cpu+0xb8/0x130
>  [<ffffffff811cf1a2>] do_filp_open+0x42/0xa0
>  [<ffffffff8169d845>] ? _raw_spin_unlock+0x35/0x60
>  [<ffffffff811dd7cd>] ? alloc_fd+0x18d/0x210
>  [<ffffffff811bc328>] do_sys_open+0xf8/0x1d0
>  [<ffffffff810faadc>] ? __audit_syscall_entry+0xcc/0x310
>  [<ffffffff811bc421>] sys_open+0x21/0x30
>  [<ffffffff816a5a69>] system_call_fastpath+0x16/0x1b
> Code: 00 00 00 e8 64 8d ab e0 48 85 c0 74 46 c7 00 00 00 00 00 48 c7 40 08
> 00 00 00 00 65 48 8b 14 25 00 c9 00 00 48 8b 92 50 05 00 00 <48> 8b 52 28
> f0 ff 42 04 48 89 50 10 48 89 83 28 01 00 00 31 c0 RIP 
> [<ffffffffa06ec54f>] tun_chr_open+0x4f/0x80 [tun]
>  RSP <ffff8800a5e29bc8>
> CR2: 0000000100000029
> Disabling lock debugging due to kernel taint
> ---[ end trace 9e00e91b0629ad80 ]---
> 
> 
> oops happened here..
> 
>         tfile->net = get_net(current->nsproxy->net_ns);
>      548:       48 8b 92 50 05 00 00    mov    0x550(%rdx),%rdx
>      54f:       48 8b 52 28             mov    0x28(%rdx),%rdx
> 
> My guess is the fuzzer called some syscall that set current->nsproxy
> to garbage (0x0000000100000001), which later got dereferenced when it
> subsequently randomly did an open() on tun.
> 
> Any thoughts ?
> 
> 	Dave
> 

I created a Bugzilla entry at 
https://bugzilla.kernel.org/show_bug.cgi?id=42960
for your bug/regression report, please add your address to the CC list in 
there, thanks!
-- 
Maciej Rutecki
http://www.mrutecki.pl
