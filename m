From: Alex Romosan <romosan@sycorax.lbl.gov>
Subject: Re: 2.6.20-rc1 sky2 problems (regression?)
Date: Thu, 14 Dec 2006 14:00:28 -0800
Message-ID: <87lklam937.fsf@sycorax.lbl.gov>
References: <87psammchi.fsf@sycorax.lbl.gov>
	<20061214133023.0b266d8e@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sycorax.lbl.gov ([128.3.5.196]:2670 "EHLO sycorax.lbl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751807AbWLNWKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 17:10:19 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061214133023.0b266d8e@freekitty> (message from Stephen
	Hemminger on Thu, 14 Dec 2006 13:30:23 -0800)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> On Thu, 14 Dec 2006 12:47:05 -0800
> Alex Romosan <romosan@sycorax.lbl.gov> wrote:
>
>> under heavy network load the sky2 driver (compiled in the kernel)
>> locks up and the only way i can get the network back is to reboot the
>> machine (bringing the network down and back up again doesn't help).
>> this happens on an amd64 machine (athlon 3500+ processor) and the card
>> in question is a Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit
>> Ethernet Controller (rev 15) (from lspci). this is what i see in the
>> syslog:
>> 
>> kernel: sky2 eth0: rx error, status 0x414a414a length 0
>> kernel: eth0: hw csum failure.
>> kernel: 
>> kernel: Call Trace:
>> kernel:  <IRQ>  [<ffffffff8044681c>] __skb_checksum_complete+0x4d/0x66
>> kernel:  [<ffffffff80477bc5>] tcp_v4_rcv+0x147/0x8ea
>> kernel:  [<ffffffff80479ef2>] raw_rcv_skb+0x9/0x20
>> kernel:  [<ffffffff8047a2ff>] raw_rcv+0xbe/0xc4
>> kernel:  [<ffffffff8045ea9d>] ip_local_deliver+0x170/0x21b
>> kernel:  [<ffffffff8045e8fa>] ip_rcv+0x478/0x4ab
>> kernel:  [<ffffffff8044905d>] netif_receive_skb+0x184/0x20e
>> kernel:  [<ffffffff803de8e5>] sky2_poll+0x68f/0x93c
>> kernel:  [<ffffffff802219ce>] scheduler_tick+0x23/0x2f9
>> kernel:  [<ffffffff8044a796>] net_rx_action+0x61/0xf0
>> kernel:  [<ffffffff8022a35f>] __do_softirq+0x40/0x8a
>> kernel:  [<ffffffff8020a3cc>] call_softirq+0x1c/0x28
>> kernel:  [<ffffffff8020bbf0>] do_softirq+0x2c/0x7d
>> kernel:  [<ffffffff8022a313>] irq_exit+0x36/0x42
>> kernel:  [<ffffffff8020bebe>] do_IRQ+0x8c/0x9e
>> kernel:  [<ffffffff80208710>] default_idle+0x0/0x3a
>> kernel:  [<ffffffff80209bf1>] ret_from_intr+0x0/0xa
>> kernel:  <EOI>  [<ffffffff80208736>] default_idle+0x26/0x3a
>> kernel:  [<ffffffff8020878c>] cpu_idle+0x42/0x75
>> kernel:  [<ffffffff805df675>] start_kernel+0x1ce/0x1d3
>> kernel:  [<ffffffff805df140>] _sinittext+0x140/0x144
>> kernel: 
>> kernel: eth0: hw csum failure.
>> kernel: 
>> kernel: Call Trace:
>> kernel:  <IRQ>  [<ffffffff8044681c>] __skb_checksum_complete+0x4d/0x66
>> kernel:  [<ffffffff80477bc5>] tcp_v4_rcv+0x147/0x8ea
>> kernel:  [<ffffffff80479ef2>] raw_rcv_skb+0x9/0x20
>> kernel:  [<ffffffff8047a2ff>] raw_rcv+0xbe/0xc4
>> kernel:  [<ffffffff8045ea9d>] ip_local_deliver+0x170/0x21b
>> kernel:  [<ffffffff8045e8fa>] ip_rcv+0x478/0x4ab
>> kernel:  [<ffffffff8044905d>] netif_receive_skb+0x184/0x20e
>> kernel:  [<ffffffff803de8e5>] sky2_poll+0x68f/0x93c
>> kernel:  [<ffffffff80474647>] tcp_delack_timer+0x0/0x1b5
>> kernel:  [<ffffffff8044a796>] net_rx_action+0x61/0xf0
>> kernel:  [<ffffffff8022a35f>] __do_softirq+0x40/0x8a
>> kernel:  [<ffffffff8020a3cc>] call_softirq+0x1c/0x28
>> kernel:  [<ffffffff8020bbf0>] do_softirq+0x2c/0x7d
>> kernel:  [<ffffffff8022a313>] irq_exit+0x36/0x42
>> kernel:  [<ffffffff8020bebe>] do_IRQ+0x8c/0x9e
>> kernel:  [<ffffffff80209bf1>] ret_from_intr+0x0/0xa
>> kernel:  <EOI>  [<ffffffff802a8402>] inode2sd+0x104/0x117
>> kernel:  [<ffffffff802b8cfa>] search_by_key+0xa08/0xbfe
>> kernel:  [<ffffffff802b8475>] search_by_key+0x183/0xbfe
>> kernel:  [<ffffffff80284778>] ll_rw_block+0x89/0x9e
>> kernel:  [<ffffffff802b8475>] search_by_key+0x183/0xbfe
>> kernel:  [<ffffffff80283cf5>] __find_get_block_slow+0x101/0x10d
>> kernel:  [<ffffffff80284053>] __find_get_block+0x197/0x1a5
>> kernel:  [<ffffffff8026800c>] inode_get_bytes+0x2a/0x52
>> kernel:  [<ffffffff802a89f1>] reiserfs_update_sd_size+0x7e/0x284
>> kernel:  [<ffffffff80237700>] kthread+0xed/0xfd
>> kernel:  [<ffffffff802be990>] do_journal_end+0x34b/0xbdd
>> kernel:  [<ffffffff802b1729>] reiserfs_dirty_inode+0x56/0x76
>> kernel:  [<ffffffff80284c19>] block_prepare_write+0x1a/0x24
>> kernel:  [<ffffffff802809b1>] __mark_inode_dirty+0x29/0x197
>> kernel:  [<ffffffff802a8d04>] reiserfs_commit_write+0x10d/0x19f
>> kernel:  [<ffffffff80284c19>] block_prepare_write+0x1a/0x24
>> kernel:  [<ffffffff802484fc>] generic_file_buffered_write+0x4ad/0x6c4
>> kernel:  [<ffffffff80271b3c>] __pollwait+0x0/0xe0
>> kernel:  [<ffffffff8022a006>] current_fs_time+0x35/0x3b
>> kernel:  [<ffffffff80248a8c>] __generic_file_aio_write_nolock+0x379/0x3ec
>> kernel:  [<ffffffff8049baca>] unix_dgram_recvmsg+0x1be/0x1d9
>> kernel:  [<ffffffff804b6516>] __mutex_lock_slowpath+0x205/0x210
>> kernel:  [<ffffffff80248b60>] generic_file_aio_write+0x61/0xc1
>> kernel:  [<ffffffff80248aff>] generic_file_aio_write+0x0/0xc1
>> kernel:  [<ffffffff80264e57>] do_sync_readv_writev+0xc0/0x107
>> kernel:  [<ffffffff802377f7>] autoremove_wake_function+0x0/0x2e
>> kernel:  [<ffffffff80229d16>] getnstimeofday+0x10/0x28
>> kernel:  [<ffffffff80264ced>] rw_copy_check_uvector+0x6c/0xdc
>> kernel:  [<ffffffff802654f7>] do_readv_writev+0xb2/0x18b
>> kernel:  [<ffffffff80265a2c>] sys_writev+0x45/0x93
>> kernel:  [<ffffffff802096de>] system_call+0x7e/0x83
>> 
>> and so on. some times i don't get this trace but instead i get:
>> 
>> kernel: sky2 eth0: tx timeout
>> kernel: sky2 eth0: transmit ring 140 .. 99 report=181 done=181
>> kernel: sky2 status report lost?
>> kernel: NETDEV WATCHDOG: eth0: transmit timed out
>> kernel: sky2 eth0: tx timeout
>> kernel: sky2 eth0: transmit ring 181 .. 140 report=181 done=181
>> kernel: sky2 hardware hung? flushing
>> 
> Pleas report these problems to netdev@vger.kernel.org, I rarely go
> looking in LKML.
>
> These are the things you need to debug a sky2 related problem.
>
> 1) What is exact kernel version in use?  This is important because
>    problems get fixed but it can be a long while until the fix bubbles down
>    to the vendor kernels.

this is stock kernel.org kernel version 2.6.20-rc1 i downloaded this
morning. 2.6.19 and 2.6.19-rc6 i referred to in my original message
were also donloaded from kernel.org.

> 2) What is the chip version?  The driver prints this out on boot up in
>    the console log.   (dmesg | grep sky2)
>    This matters because each chip version has different
>    bugs to deal with.

sky2 v1.10 addr 0xfddfc000 irq 17 Yukon-EC (0xb6) rev 1
sky2 eth0: addr 00:11:09:da:39:a3
sky2 eth0: enabling interface
sky2 eth0: ram buffer 48K
sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both


> 3) Does it work with the vendor driver?
>    The vendor driver does a number of things differently than the sky2 driver
>    and can mask problems, but if it doesn't work as well that is a useful
>    data point.  If you want to know why the sky2 driver was written instead
>    of just using the vendor driver, look at the code. The sk98lin driver
>    is huge, includes features that are unsupportable and broken, and locking
>    mistakes.  But the sk98lin also has a watchdog that masks off bugs and
>    may provide useful insight.

i haven't tried the vendor driver yet, but i guess i will, and let you
know what happens.

> 4) What is the IRQ routing?
>    There are two issues here, first the driver will never work with edge
>    trigger IRQ's, some motherboards also have busted BIOS and chipsets
>    that don't do MSI properly. A couple of module parameters are available
>    to help:
>       disable_msi=1   		avoids using MSI
>       idle_timeout=10		polls for lost IRQ's every N ms (10)

hmm, i have MSI interrupts enabled in the config and cat
/proc/interrups gives me:

283:    1474208   PCI-MSI-edge      eth0

so you say i should dissable msi?

> 5) What are the messages in the console log when problem happens?

see my original message i kept above.

> 6) Are you running any of the following: bonding, vlans, bridging,
>    netfilter, traffic control?

no.

> 7) Please get a current version of ethtool from:
>    git://git.kernel.org/pub/scm/network/ethtool/ethtool.git
>    and run ethtool register dump after a problem occurs:
>       ethtool -d eth0

i've downloaded it and i'll run it next time the machine locks up.

> 8) Are you using a dual port board.  There were issues on the PCI-X
>    version that required hacks, the PCI-express version may have the
>    same problem.  Basically, checksum offload wouldn't work and receive
>    DMA's would arrive out of order.

it is a dual port board but i am using only one port.

--alex--

-- 
| I believe the moment is at hand when, by a paranoiac and active |
|  advance of the mind, it will be possible (simultaneously with  |
|  automatism and other passive states) to systematize confusion  |
|  and thus to help to discredit completely the world of reality. |
