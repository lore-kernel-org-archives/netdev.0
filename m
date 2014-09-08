From: Andres Freund <andres@anarazel.de>,
	"Alexander Y. Fomichev" <git.user@gmail.com>
Subject: Macvlan WARNiNGS about duplicate sysfs filenames (Was [GIT]
 Networking)
Date: Mon, 8 Sep 2014 23:25:14 +0200
Message-ID: <20140908212514.GA2348@awork2.anarazel.de>
References: <20140907.164109.1944849896872238507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140907.164109.1944849896872238507.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

(don't have netdev archived, thus answering here, sorry)

On 2014-09-07 16:41:09 -0700, David Miller wrote:
> Alexander Y. Fomichev (1):
>       net: prevent of emerging cross-namespace symlinks

I'm seeing WARNINGs like:
[ 1005.269134] ------------[ cut here ]------------
[ 1005.269148] WARNING: CPU: 6 PID: 4213 at fs/sysfs/dir.c:31 sysfs_warn_dup+0x64/0x80()
[ 1005.269150] sysfs: cannot create duplicate filename '/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/net/eth0/upper_mv-eth0'
[ 1005.269152] Modules linked in: nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ipt_REJECT iptable_filter ip_tables snd_hda_code
c_ca0110 snd_hda_codec_realtek snd_hda_codec_generic snd_hda_codec_hdmi snd_hda_intel snd_hda_controller snd_hda_codec snd_hwdep snd_pcm acpi
_cpufreq w83793 jc42 e1000e ptp pps_core
[ 1005.269175] CPU: 6 PID: 4213 Comm: systemd-nspawn Tainted: G        W I    3.17.0-rc4-andres-00135-g35af256 #216
[ 1005.269178] Hardware name: empty empty/S7020, BIOS 'V1.03  ' 03/09/2010
[ 1005.269180]  0000000000000009 ffff8803300b3738 ffffffff81cc0ca2 ffff8803300b3780
[ 1005.269183]  ffff8803300b3770 ffffffff8111434d ffff88062ce1a000 ffff8803300b3851
[ 1005.269186]  ffff88032e5d4c30 ffff88032e5d4c30 ffffffffffffffef ffff8803300b37d0
[ 1005.269190] Call Trace:
[ 1005.269198]  [<ffffffff81cc0ca2>] dump_stack+0x45/0x56
[ 1005.269203]  [<ffffffff8111434d>] warn_slowpath_common+0x7d/0xa0
[ 1005.269206]  [<ffffffff811143bc>] warn_slowpath_fmt+0x4c/0x50
[ 1005.269209]  [<ffffffff812c5dc8>] ? kernfs_path+0x48/0x60
[ 1005.269213]  [<ffffffff812c9464>] sysfs_warn_dup+0x64/0x80
[ 1005.269216]  [<ffffffff812c97be>] sysfs_do_create_link_sd.isra.2+0x9e/0xb0
[ 1005.269219]  [<ffffffff812c97f5>] sysfs_create_link+0x25/0x50
[ 1005.269227]  [<ffffffff81b73238>] netdev_adjacent_sysfs_add+0x58/0x70
[ 1005.269232]  [<ffffffff81b75ebd>] __netdev_adjacent_dev_insert+0x15d/0x1b0
[ 1005.269236]  [<ffffffff81b75f41>] __netdev_adjacent_dev_link_lists+0x31/0x80
[ 1005.269240]  [<ffffffff81b760e6>] __netdev_upper_dev_link+0x156/0x480
[ 1005.269245]  [<ffffffff81b70cb5>] ? call_netdevice_notifiers_info+0x35/0x60
[ 1005.269250]  [<ffffffff81b76422>] netdev_upper_dev_link+0x12/0x20
[ 1005.269257]  [<ffffffff819b7822>] macvlan_common_newlink+0x182/0x3f0
[ 1005.269261]  [<ffffffff819b7a9e>] macvlan_newlink+0xe/0x10
[ 1005.269267]  [<ffffffff81b87cf4>] rtnl_newlink+0x6d4/0x790
[ 1005.269270]  [<ffffffff81b8779f>] ? rtnl_newlink+0x17f/0x790
[ 1005.269278]  [<ffffffff81b86722>] rtnetlink_rcv_msg+0x92/0x260
[ 1005.269284]  [<ffffffff81247e71>] ? __kmalloc_node_track_caller+0x181/0x210
[ 1005.269294]  [<ffffffff8160e556>] ? rhashtable_lookup_compare+0x36/0x70
[ 1005.269299]  [<ffffffff81b86690>] ? rtnetlink_rcv+0x30/0x30
[ 1005.269307]  [<ffffffff81ba5679>] netlink_rcv_skb+0xa9/0xd0
[ 1005.269312]  [<ffffffff81b86688>] rtnetlink_rcv+0x28/0x30
[ 1005.269316]  [<ffffffff81ba4bda>] netlink_unicast+0x10a/0x1a0
[ 1005.269321]  [<ffffffff81ba508c>] netlink_sendmsg+0x34c/0x780
[ 1005.269328]  [<ffffffff811fc2c6>] ? free_hot_cold_page_list+0x46/0xa0
[ 1005.269334]  [<ffffffff81b5bb03>] sock_sendmsg+0x73/0x90
[ 1005.269343]  [<ffffffff812228c3>] ? unmap_region+0xd3/0x110
[ 1005.269350]  [<ffffffff81271703>] ? __fdget+0x13/0x20
[ 1005.269355]  [<ffffffff81b5d381>] ? move_addr_to_kernel+0x31/0x90
[ 1005.269360]  [<ffffffff81b5dd23>] SyS_sendto+0x113/0x150
[ 1005.269366]  [<ffffffff81607eab>] ? trace_hardirqs_on_thunk+0x3a/0x3c
[ 1005.269374]  [<ffffffff81cceb56>] system_call_fastpath+0x1a/0x1f
[ 1005.269377] ---[ end trace 00724f5b901e5d10 ]---

which are quite justified:

# readlink -f /sys/devices/pci0000:00/0000:00:1c.4/0000:03:00.0/net/eth0/upper_mv-eth0
/sys/devices/virtual/net/mv-eth0
# ls -l /sys/devices/virtual/net/mv-eth0
ls: cannot access /sys/devices/virtual/net/mv-eth0: No such file or directory

That happened after bringing up mv-eth0 up once, then down, and then up
again. There apparently is a dangling symlink somewhere. I'd done this
via:
systemd-nspawn -b -j -D /home/andres/chroot/sid-amd64 --private-network --network-macvlan=eth0

I haven't used macvlan before, so it's not impossible that the bug has
existed for longer. It's also possible that this bug isn't the fault of
this patch. I think both aren't terribly likely though.

Greetings,

Andres Freund
