From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: net-next: warnings from sysctl_net_exit
Date: Tue, 1 Mar 2011 23:09:54 -0800
Message-ID: <20110301230954.7f34f1ea@nehalam>
References: <AANLkTi=mhj3Ftq8hFPPzZYJvp8mgOeV89oX_vHZVxwzY@mail.gmail.com>
	<20110227160852.4f748c1f@nehalam>
	<AANLkTinL3UhjOtmr3uyEkSiDT5NFJo=FbG5mKm3XaU8R@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51220 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751701Ab1CBHJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 02:09:57 -0500
In-Reply-To: <AANLkTinL3UhjOtmr3uyEkSiDT5NFJo=FbG5mKm3XaU8R@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Feb 2011 03:11:46 +0200
Lucian Adrian Grijincu <lucian.grijincu@gmail.com> wrote:

> On Mon, Feb 28, 2011 at 2:08 AM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> >> The check is triggered at network namespace deletion, so a moment
> >> before deleting the netns should be fine.
> >
> > Although the kernel was compiled with netns, I never use net namespaces.
> 
> 
> This can be triggered at shutdown when the init_net network namespace
> is dismantled.
> 
> Are you getting this at shutdown time? If not, is it easily reproducible?
> Can you post a .config?
> 

It seems to happen right after ip6tables starts at boot.
I added more backtrace info to walk the list of remaining entries,
and got this but it doesn't help much.

[   59.700687] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   60.413111] header=ffff8803239db000 count=1 used=0 unregistering=          (null)
[   60.413113]   procname=net
[   60.413115] ------------[ cut here ]------------
[   60.413119] WARNING: at net/sysctl_net.c:98 sysctl_net_exit+0x94/0x9d()
[   60.413121] Hardware name: System Product Name
[   60.413122] Modules linked in: ip6table_filter ip6_tables nfs lockd fscache nfs_acl auth_rpcgss sunrpc binfmt_misc ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm snd_hda_codec_analog lm63 radeon snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq ttm psmouse snd_timer drm_kms_helper serio_raw snd_seq_device pl2303 usbserial snd drm soundcore i7core_edac snd_page_alloc edac_core asus_atk0110 i2c_algo_bit hid_belkin usbhid hid pata_marvell ahci sky2 libahci igb e1000e dca floppy btrfs lzo_compress zlib_deflate crc32c libcrc32c
[   60.413170] Pid: 67, comm: kworker/u:5 Not tainted 2.6.38-rc5-net-next+ #19
[   60.413171] Call Trace:
[   60.413176]  [<ffffffff81040dce>] ? warn_slowpath_common+0x85/0x9d
[   60.413180]  [<ffffffff8136183a>] ? cleanup_net+0x0/0x19a
[   60.413182]  [<ffffffff81040e00>] ? warn_slowpath_null+0x1a/0x1c
[   60.413184]  [<ffffffff81414ebb>] ? sysctl_net_exit+0x94/0x9d
[   60.413187]  [<ffffffff81361492>] ? ops_exit_list+0x2a/0x5b
[   60.413189]  [<ffffffff81361934>] ? cleanup_net+0xfa/0x19a
[   60.413193]  [<ffffffff810575bd>] ? process_one_work+0x233/0x3aa
[   60.413196]  [<ffffffff81057524>] ? process_one_work+0x19a/0x3aa
[   60.413199]  [<ffffffff810599be>] ? worker_thread+0x13b/0x25a
[   60.413201]  [<ffffffff81059883>] ? worker_thread+0x0/0x25a
[   60.413204]  [<ffffffff8105d0f1>] ? kthread+0x9d/0xa5
[   60.413207]  [<ffffffff8106d614>] ? trace_hardirqs_on_caller+0x10c/0x130
[   60.413210]  [<ffffffff810030d4>] ? kernel_thread_helper+0x4/0x10
[   60.413215]  [<ffffffff8142ed40>] ? restore_args+0x0/0x30
[   60.413217]  [<ffffffff8105d054>] ? kthread+0x0/0xa5
[   60.413219]  [<ffffffff810030d0>] ? kernel_thread_helper+0x0/0x10
[   60.413221] ---[ end trace 9b655d61bf30c4f8 ]---
