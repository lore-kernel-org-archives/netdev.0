From: Eric Dumazet <edumazet@google.com>
Subject: Re: [v4.6-rc7-183-g1410b74e4061]
Date: Sat, 14 May 2016 09:46:53 -0700
Message-ID: <CANn89iJpEm9FLJ1_1Bkbf=ke785kA4MYH6=4o03_48n2nOtCyA@mail.gmail.com>
References: <CA+icZUXF9DkymNNGwP8zzmKY9PRAPGFZ+7p9En1xy80FcX_RRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Peter Zijlstra <peterz@infradead.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alfredo Alvarez Fernandez <alfredoalvarezfernandez@gmail.com>
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+icZUXF9DkymNNGwP8zzmKY9PRAPGFZ+7p9En1xy80FcX_RRw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 14, 2016 at 2:22 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> Hi,
>
> as Linux v4.6 is very near, I decided to write this bug report (only
> drunk one coffee).
>
> First, I am not absolutely sure if this is a real issue as...
> #1: This is only a (lockdep) warning.
> #2: I have not a "vanilla" Linux v4.6-rc7+ here (see P.S. and attached patch)
>
> For a more helpful feedback I should test a...
> #1: vanilla v4.6-rc7-183-g1410b74e4061
> #2: net.git#master on top of #1
>
> What I am seeing is this while surfing with a UMTS/HSPA internet-stick
> (using PPP) and running Firefox on Ubuntu/precise AMD64...
>
> [  423.484105] ------------[ cut here ]------------
> [  423.484119] WARNING: CPU: 2 PID: 2392 at
> kernel/locking/lockdep.c:2098 __lock_acquire
> [  423.484123] DEBUG_LOCKS_WARN_ON(chain_hlocks[chain->base
> [  423.484125] Modules linked in: btrfs xor raid6_pq ntfs xfs
> libcrc32c ppp_deflate bsd_comp ppp_async crc_ccitt option usb_wwan
> cdc_ether usbserial usbnet snd_hda_codec_hdmi i915
> snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel
> snd_hda_codec arc4 uvcvideo iwldvm snd_hwdep joydev mac80211
> videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_core
> videodev rfcomm bnep kvm_intel kvm usb_storage btusb i2c_algo_bit
> iwlwifi btrtl snd_hda_core drm_kms_helper btbcm snd_pcm parport_pc
> btintel syscopyarea irqbypass ppdev snd_seq_midi bluetooth sysfillrect
> psmouse snd_seq_midi_event sysimgblt snd_rawmidi fb_sys_fops cfg80211
> snd_seq drm serio_raw snd_timer samsung_laptop snd_seq_device snd
> soundcore wmi mac_hid video intel_rst lpc_ich lp parport binfmt_misc
> hid_generic usbhid hid r8169 mii
> [  423.484241] CPU: 2 PID: 2392 Comm: firefox Not tainted
> 4.6.0-rc7-183.1-iniza-small #1
> [  423.484244] Hardware name: SAMSUNG ELECTRONICS CO., LTD.
> 530U3BI/530U4BI/530U4BH/530U3BI/530U4BI/530U4BH, BIOS 13XK 03/28/2013
> [  423.484247]  0000000000000000 ffff88011fa83910 ffffffff81413825
> ffff88011fa83960
> [  423.484253]  0000000000000000 ffff88011fa83950 ffffffff81083ea1
> 0000083282f34ec0
> [  423.484259]  0000000000000005 ffff880082f34540 0000000000000000
> 0000000000000027
> [  423.484265] Call Trace:
> [  423.484268]  <IRQ>  [<ffffffff81413825>] dump_stack
> [  423.484280]  [<ffffffff81083ea1>] __warn
> [  423.484285]  [<ffffffff81083f0f>] warn_slowpath_fmt
> [  423.484289]  [<ffffffff810dee38>] __lock_acquire
> [  423.484294]  [<ffffffff810de294>] ? __lock_acquire
> [  423.484298]  [<ffffffff810de294>] ? __lock_acquire
> [  423.484302]  [<ffffffff810e0869>] lock_acquire
> [  423.484307]  [<ffffffff81711c3b>] ? __dev_queue_xmit
> [  423.484313]  [<ffffffff81823ce8>] _raw_spin_lock
> [  423.484317]  [<ffffffff81711c3b>] ? __dev_queue_xmit
> [  423.484321]  [<ffffffff81711c3b>] __dev_queue_xmit
> [  423.484326]  [<ffffffff81711640>] ? __dev_queue_xmit
> [  423.484330]  [<ffffffff81711e30>] dev_queue_xmit
> [  423.484334]  [<ffffffff8171a291>] neigh_direct_output
> [  423.484339]  [<ffffffff8175566c>] ip_finish_output2
> [  423.484344]  [<ffffffff817554ff>] ? ip_finish_output2
> [  423.484349]  [<ffffffff817565ba>] ip_finish_output
> [  423.484353]  [<ffffffff81757e81>] ip_output
> [  423.484357]  [<ffffffff810dbbb9>] ? __lock_is_held
> [  423.484362]  [<ffffffff8175737d>] ip_local_out
> [  423.484366]  [<ffffffff817577a5>] ip_queue_xmit
> [  423.484371]  [<ffffffff817575c5>] ? ip_queue_xmit
> [  423.484376]  [<ffffffff81771296>] tcp_transmit_skb
> [  423.484380]  [<ffffffff817737ea>] __tcp_retransmit_skb
> [  423.484385]  [<ffffffff81773e97>] tcp_retransmit_skb
> [  423.484389]  [<ffffffff817754b7>] tcp_retransmit_timer
> [  423.484394]  [<ffffffff81775bd0>] ? tcp_write_timer_handler
> [  423.484398]  [<ffffffff81775a7c>] tcp_write_timer_handler
> [  423.484402]  [<ffffffff81775c50>] tcp_write_timer
> [  423.484407]  [<ffffffff81104f84>] call_timer_fn
> [  423.484411]  [<ffffffff81104ef5>] ? call_timer_fn
> [  423.484416]  [<ffffffff81775bd0>] ? tcp_write_timer_handler
> [  423.484419]  [<ffffffff811058f5>] run_timer_softirq
> [  423.484424]  [<ffffffff81827632>] __do_softirq
> [  423.484428]  [<ffffffff8108b2fe>] irq_exit
> [  423.484432]  [<ffffffff818272c2>] smp_apic_timer_interrupt
> [  423.484437]  [<ffffffff818253c6>] apic_timer_interrupt
> [  423.484439]  <EOI>
> [  423.484443] ---[ end trace a29d8ee0ef420d5c ]---
> [  423.484446]
> [  423.484447] ======================
> [  423.484449] [chain_key collision ]
> [  423.484452] 4.6.0-rc7-183.1-iniza-small #1 Tainted: G        W
> [  423.484454] ----------------------
> [  423.484457] firefox/2392: Hash chain already cached but the
> contents don't match!
> [  423.484460] Held locks:depth: 6
> [  423.484463]  class_idx:1993 -> chain_key:00000000000007c9
> (((&icsk->icsk_retransmit_timer))){
> [  423.484473]  class_idx:1334 -> chain_key:0000000000f92536 (slock-AF_INET){
> [  423.484482]  class_idx:33 -> chain_key:0000001f24a6c021
> (rcu_read_lock){......}, at: [<ffffffff817575c5>] ip_queue_xmit
> [  423.484492]  class_idx:1005 -> chain_key:0003e494d80423ed
> (rcu_read_lock_bh){......}, at: [<ffffffff817554ff>] ip_finish_output2
> [  423.484500]  class_idx:1005 -> chain_key:7c929b00847da3ed
> (rcu_read_lock_bh){......}, at: [<ffffffff81711640>] __dev_queue_xmit
> [  423.484509]  class_idx:1996 -> chain_key:5360108fb47da85e
> (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){
> [  423.484517] Locks in cached chain:depth: 6
> [  423.484520]  class_idx:1998 -> chain_key:00000000000007ce
> (((&sk->sk_timer))){
> [  423.484525]  class_idx:1334 -> chain_key:0000000000f9c536 (slock-AF_INET){
> [  423.484531]  class_idx:33 -> chain_key:0000001f38a6c021
> (rcu_read_lock){......}
> [  423.484536]  class_idx:1005 -> chain_key:0003e714d80423ed
> (rcu_read_lock_bh){......}
> [  423.484541]  class_idx:1005 -> chain_key:7ce29b00847da3ed
> (rcu_read_lock_bh){......}
> [  423.484547]  class_idx:1986 -> chain_key:5360108fb47da85e (_xmit_PPP#2){
> [  423.484553]
> [  423.484553] stack backtrace:
> [  423.484558] CPU: 2 PID: 2392 Comm: firefox Tainted: G        W
>  4.6.0-rc7-183.1-iniza-small #1
> [  423.484561] Hardware name: SAMSUNG ELECTRONICS CO., LTD.
> 530U3BI/530U4BI/530U4BH/530U3BI/530U4BI/530U4BH, BIOS 13XK 03/28/2013
> [  423.484563]  0000000000000000 ffff88011fa83968 ffffffff81413825
> 0000000000000006
> [  423.484570]  ffffffff82189c20 ffff88011fa839b0 ffffffff811a8190
> 000000041fa83980
> [  423.484575]  ffff880082f34e48 0000000000000005 ffff880082f34540
> 0000000000000000
> [  423.484581] Call Trace:
> [  423.484584]  <IRQ>  [<ffffffff81413825>] dump_stack
> [  423.484592]  [<ffffffff811a8190>] print_collision
> [  423.484597]  [<ffffffff810dee4d>] __lock_acquire
> [  423.484601]  [<ffffffff810de294>] ? __lock_acquire
> [  423.484606]  [<ffffffff810de294>] ? __lock_acquire
> [  423.484610]  [<ffffffff810e0869>] lock_acquire
> [  423.484615]  [<ffffffff81711c3b>] ? __dev_queue_xmit
> [  423.484619]  [<ffffffff81823ce8>] _raw_spin_lock
> [  423.484624]  [<ffffffff81711c3b>] ? __dev_queue_xmit
> [  423.484628]  [<ffffffff81711c3b>] __dev_queue_xmit
> [  423.484632]  [<ffffffff81711640>] ? __dev_queue_xmit
> [  423.484636]  [<ffffffff81711e30>] dev_queue_xmit
> [  423.484640]  [<ffffffff8171a291>] neigh_direct_output
> [  423.484644]  [<ffffffff8175566c>] ip_finish_output2
> [  423.484648]  [<ffffffff817554ff>] ? ip_finish_output2
> [  423.484653]  [<ffffffff817565ba>] ip_finish_output
> [  423.484657]  [<ffffffff81757e81>] ip_output
> [  423.484661]  [<ffffffff810dbbb9>] ? __lock_is_held
> [  423.484666]  [<ffffffff8175737d>] ip_local_out
> [  423.484670]  [<ffffffff817577a5>] ip_queue_xmit
> [  423.484675]  [<ffffffff817575c5>] ? ip_queue_xmit
> [  423.484679]  [<ffffffff81771296>] tcp_transmit_skb
> [  423.484683]  [<ffffffff817737ea>] __tcp_retransmit_skb
> [  423.484688]  [<ffffffff81773e97>] tcp_retransmit_skb
> [  423.484692]  [<ffffffff817754b7>] tcp_retransmit_timer
> [  423.484697]  [<ffffffff81775bd0>] ? tcp_write_timer_handler
> [  423.484701]  [<ffffffff81775a7c>] tcp_write_timer_handler
> [  423.484705]  [<ffffffff81775c50>] tcp_write_timer
> [  423.484709]  [<ffffffff81104f84>] call_timer_fn
> [  423.484713]  [<ffffffff81104ef5>] ? call_timer_fn
> [  423.484718]  [<ffffffff81775bd0>] ? tcp_write_timer_handler
> [  423.484730]  [<ffffffff811058f5>] run_timer_softirq
> [  423.484734]  [<ffffffff81827632>] __do_softirq
> [  423.484738]  [<ffffffff8108b2fe>] irq_exit
> [  423.484742]  [<ffffffff818272c2>] smp_apic_timer_interrupt
> [  423.484746]  [<ffffffff818253c6>] apic_timer_interrupt
>
> NOTE: I realized this call-trace 1st after v4.6-rc7.
>
> The only commit I see which might have an effect is...
>
> 10a81980fc47 tcp: refresh skb timestamp at retransmit time
>
> ...but I may be wrong.
>
> So help in...
> "No more darkness, no more night." ---> " I see the light, I see the light."
>
> Attached is my linux-config, dmesg output and "customized" patch.
>
> Pleas give some clear instructions to get more light in debugging this.
>
> I'm really in a hurry, so sorry if this BR is unsatisfying and incomplete.
>
> Regards,
> - Sedat -
>
> P.S.: For more details see attached patch on top of Linux v4.6-rc7.
>
> Sedat Dilek (5):
>       Merge branch 'wb-buf-throttle' of
> git://git.kernel.org/.../axboe/linux-block into
> for-4.8/wb-buf-throttle-20160510
>       Merge branch 'for-4.6/vfs-fixes' into 4.6.0-rc7-183.1-iniza-small
>       Merge branch 'for-4.6/net-fixes' into 4.6.0-rc7-183.1-iniza-small
>       Merge branch 'for-4.7/pm-next-20160513' into 4.6.0-rc7-183.1-iniza-small
>       Merge branch 'for-4.8/wb-buf-throttle-20160510' into
> 4.6.0-rc7-183.1-iniza-small
>
> P.S.S: Investigating net/ changes since Linux v4.6-rc7.
>
> $ git log --oneline v4.6-rc7.. net/
> e271c7b4420d gre: do not keep the GRE header around in collect medata mode
> 16ec3d4fbb96 openvswitch: Fix cached ct with helper.
> 4e8c86155010 net sched: ife action fix late binding
> 5e1567aeb7fe net sched: skbedit action fix late binding
> 0e5538ab2b59 net sched: simple action fix late binding
> 87dfbdc6c747 net sched: mirred action fix late binding
> a57f19d30b2d net sched: ipt action fix late binding
> 5026c9b1bafc net sched: vlan action fix late binding
> 10a81980fc47 tcp: refresh skb timestamp at retransmit time
> adc0a8bfdc52 Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf
> 79e48650320e net: fix a kernel infoleak in x25 module
> 229740c63169 udp_offload: Set encapsulation before inner completes.
> 43b8448cd7b4 udp_tunnel: Remove redundant udp_tunnel_gro_complete().
> 1d2f7b2d956e net: ipv6: tcp reset, icmp need to consider L3 domain
> 856ce5d083e1 bridge: fix igmp / mld query parsing
> 31ca0458a61a net: bridge: fix old ioctl unlocked net device walk
> dedc58e067d8 VSOCK: do not disconnect socket when peer has shutdown SEND only
> eda3fc50daa9 netfilter: nfnetlink_acct: validate NFACCT_QUOTA parameter
> 32b583a0cb9b Merge branch 'master' of
> git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec
> 5f8e44741f9f net: fix infoleak in rtnetlink
> b8670c09f37b net: fix infoleak in llc
> cec5913c1515 netfilter: IDLETIMER: fix race condition when destroy the target
> 70d72b7e060e netfilter: conntrack: init all_locks to avoid debug warning
> d6af1a31cc72 vti: Add pmtu handling to vti_xmit.
> 215276c0147e xfrm: Reset encapsulation field of the skb before transformation
> 6ad3122a08e3 flowcache: Avoid OOM condition under preasure


This looks like a hash collision lockdep report, exposed by a recent commit

I have no idea how to proceed at this point.

commit 39e2e173fb1f900959d3a25c21c65fa88b06c6ee
Author: Alfredo Alvarez Fernandez <alfredoalvarezfernandez@gmail.com>
Date:   Wed Mar 30 19:03:36 2016 +0200

    locking/lockdep: Print chain_key collision information

    A sequence of pairs [class_idx -> corresponding chain_key iteration]
    is printed for both the current held_lock chain and the cached chain.

    That exposes the two different class_idx sequences that led to that
    particular hash value.

    This helps with debugging hash chain collision reports.

    Signed-off-by: Alfredo Alvarez Fernandez <alfredoalvarezfernandez@gmail.com>
    Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
    Cc: Linus Torvalds <torvalds@linux-foundation.org>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: linux-fsdevel@vger.kernel.org
    Cc: sedat.dilek@gmail.com
    Cc: tytso@mit.edu
    Link: http://lkml.kernel.org/r/1459357416-19190-1-git-send-email-alfredoalvarezernandez@gmail.com
    Signed-off-by: Ingo Molnar <mingo@kernel.org>
