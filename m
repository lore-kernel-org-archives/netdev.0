From: Andrew Morton <akpm@linux-foundation.org>
Subject: inet6_ifa_finish_destroy() blurt
Date: Tue, 23 Mar 2010 15:35:20 -0700
Message-ID: <20100323153520.3869ec5d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60795 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753102Ab0CWWfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 18:35:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Got this during boot using today's linux-next.  The
WARN_ON(!hlist_unhashed(&ifp->addr_lst)) triggered. 

c2e21293c054817c42eb5fa9c613d2ad51954136 ("ipv6: convert addrconf list
to hlist") added it.



[   53.677562] calling  init_autofs4_fs+0x0/0x23 [autofs4] @ 3535
[   53.677931] initcall init_autofs4_fs+0x0/0x23 [autofs4] returned 0 after 57 usecs
[  247.122112] ------------[ cut here ]------------
[  247.122187] WARNING: at net/ipv6/addrconf.c:544 inet6_ifa_finish_destroy+0x24/0x9b [ipv6]()
[  247.122244] Modules linked in: autofs4 sunrpc ipv6 dm_mirror dm_region_hash dm_log dm_multipath dm_mod video output sbs sbshc battery ac lp parport sg ide_cd_mod cdrom serio_raw floppy snd_hda_intel snd_hda_codec snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device button snd_pcm_oss snd_mixer_oss snd_pcm i2c_i801 i2c_core pcspkr snd_timer snd soundcore snd_page_alloc shpchp ehci_hcd ohci_hcd uhci_hcd
[  247.124152] Pid: 0, comm: swapper Not tainted 2.6.34-rc2-mm1+ #1
[  247.124208] Call Trace:
[  247.124255]  <IRQ>  [<ffffffffa01941d3>] ? inet6_ifa_finish_destroy+0x24/0x9b [ipv6]
[  247.124369]  [<ffffffff81035489>] warn_slowpath_common+0x7e/0x97
[  247.124425]  [<ffffffff810354b7>] warn_slowpath_null+0x15/0x17
[  247.124487]  [<ffffffffa01941d3>] inet6_ifa_finish_destroy+0x24/0x9b [ipv6]
[  247.124550]  [<ffffffffa019666b>] addrconf_prefix_rcv+0x546/0x713 [ipv6]
[  247.124609]  [<ffffffff812d7625>] ? neigh_update+0x3cc/0x3ec
[  247.124669]  [<ffffffffa01a01ac>] ndisc_rcv+0xa45/0xf2c [ipv6]
[  247.124723]  [<ffffffff812d80d1>] ? rtnl_notify+0x2b/0x2d
[  247.124785]  [<ffffffffa0199962>] ? inet6_rt_notify+0x104/0x129 [ipv6]
[  247.124851]  [<ffffffffa01a5dd5>] icmpv6_rcv+0x5cb/0x66b [ipv6]
[  247.124919]  [<ffffffffa01986b4>] ? __ip6_ins_rt+0x3d/0x48 [ipv6]
[  247.124976]  [<ffffffff8135b0fd>] ? _raw_read_unlock_bh+0x12/0x14
[  247.125041]  [<ffffffffa01a83e7>] ? ipv6_chk_mcast_addr+0x129/0x14f [ipv6]
[  247.125104]  [<ffffffffa0192184>] ip6_input_finish+0x19f/0x28b [ipv6]
[  247.125167]  [<ffffffffa0191b62>] ip6_input+0x4a/0x4e [ipv6]
[  247.125227]  [<ffffffffa0191c4d>] ip6_mc_input+0xc3/0xd4 [ipv6]
[  247.125288]  [<ffffffffa0191b86>] ip6_rcv_finish+0x20/0x24 [ipv6]
[  247.125351]  [<ffffffffa0191fac>] ipv6_rcv+0x34e/0x387 [ipv6]
[  247.125407]  [<ffffffff812d03fd>] __netif_receive_skb+0x4bf/0x4e4
[  247.125460]  [<ffffffff812d0515>] netif_receive_skb+0x24/0x32
[  247.125515]  [<ffffffff812d0bbf>] napi_skb_finish+0x21/0x37
[  247.125569]  [<ffffffff812d0bff>] napi_gro_receive+0x2a/0x2f
[  247.125625]  [<ffffffff8125e7e2>] e1000_receive_skb+0x60/0x69
[  247.125678]  [<ffffffff812606f6>] e1000_clean_rx_irq+0x240/0x2da
[  247.125734]  [<ffffffff8126241c>] e1000_clean+0x79/0x224
[  247.125788]  [<ffffffff812d06e4>] net_rx_action+0xca/0x1da
[  247.125841]  [<ffffffff8103a502>] __do_softirq+0x9e/0x11f
[  247.125895]  [<ffffffff8100390c>] call_softirq+0x1c/0x28
[  247.125950]  [<ffffffff81004ff5>] do_softirq+0x33/0x6a
[  247.126002]  [<ffffffff8103a42e>] irq_exit+0x38/0x3a
[  247.126055]  [<ffffffff81004ebc>] do_IRQ+0xaa/0xc1
[  247.126108]  [<ffffffff8135b393>] ret_from_intr+0x0/0xa
[  247.126159]  <EOI>  [<ffffffff81009d13>] ? mwait_idle+0x59/0x5e
[  247.126260]  [<ffffffff8100104a>] ? enter_idle+0x20/0x22
[  247.126425]  [<ffffffff810014c5>] cpu_idle+0x43/0x61
[  247.126591]  [<ffffffff81355389>] start_secondary+0x1aa/0x1ae
[  247.126757]  [<ffffffff813551df>] ? start_secondary+0x0/0x1ae
[  247.126922] ---[ end trace ea6028b997f8cf89 ]---
[  247.127085] Freeing alive inet6 address ffff88025d872a80
