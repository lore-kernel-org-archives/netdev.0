From: "Ming Lei" <tom.leiming@gmail.com>
Subject: BUG:tg3_open() bug
Date: Tue, 5 Aug 2008 22:32:26 +0800
Message-ID: <d82e647a0808050732u8c5343doba5cd7bc7248087c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:3844 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755410AbYHEOc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 10:32:29 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2278665fkq.5
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 07:32:26 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

kernel :  2.6.27-rc1-00526-g5ede58d
The following message is produced by running "ifconfig eth0 up".

Thanks,

ADDRCONF(NETDEV_UP): eth0: link is not ready
tg3: eth0: Link is up at 100 Mbps, full duplex.
tg3: eth0: Flow control is on for TX and on for RX.
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
BUG: scheduling while atomic: ifconfig/3345/0x00000102
2 locks held by ifconfig/3345:
 #0:  (rtnl_mutex){....}, at: [<ffffffff803c0086>] rtnl_lock+0x17/0x19
 #1:  (&tp->lock){....}, at: [<ffffffffa01afd55>] tg3_open+0x44/0x71e [tg3]
Modules linked in: autofs4 sunrpc ipv6 acpi_cpufreq arc4 snd_hda_intel
ecb usbhid snd_seq_device snd_pcm_oss snd_mixer_oss crypto_blkcipher
snd_pcm usbmouse snd_timer snd_page_alloc snd_hwdep thermal tg3
ohci1394 snd ieee1394 cryptomgr crypto_algapi processor iwl3945
mac80211 led_class cfg80211 libphy button battery i2c_i801 ac i2c_core
sg sr_mod dcdbas evdev cdrom ata_piix ata_generic libata dock sd_mod
scsi_mod ext3 jbd mbcache uhci_hcd ehci_hcd usbcore [last unloaded:
microcode]
Pid: 3345, comm: ifconfig Not tainted 2.6.27-rc1-00526-g5ede58d #50

Call Trace:
 [<ffffffff8025425d>] ? __debug_show_held_locks+0x22/0x24
 [<ffffffff8022e1fd>] __schedule_bug+0x8c/0x95
 [<ffffffff8042a809>] schedule+0xa2/0x841
 [<ffffffff8023d7d7>] ? __mod_timer+0xe2/0xf4
 [<ffffffff8025343e>] ? lock_release_holdtime+0x56/0x5e
 [<ffffffff8042b2b9>] schedule_timeout+0x92/0xb9
 [<ffffffff8023d29f>] ? process_timeout+0x0/0x10
 [<ffffffff8042b2b4>] ? schedule_timeout+0x8d/0xb9
 [<ffffffff8042b2fe>] schedule_timeout_uninterruptible+0x1e/0x20
 [<ffffffff8023d802>] msleep+0x19/0x23
 [<ffffffff803241df>] pci_set_power_state+0x1d2/0x297
 [<ffffffff803219db>] ? pci_bus_write_config_dword+0x69/0x78
 [<ffffffffa01a946d>] tg3_set_power_state+0x66/0x8b3 [tg3]
 [<ffffffffa01afd5f>] tg3_open+0x4e/0x71e [tg3]
 [<ffffffff80238a2a>] ? local_bh_enable_ip+0xbf/0xdc
 [<ffffffff803b8896>] dev_open+0x78/0xad
 [<ffffffff803b6658>] dev_change_flags+0xb0/0x16c
 [<ffffffff803f6765>] devinet_ioctl+0x26e/0x5df
 [<ffffffff803f769a>] inet_ioctl+0x97/0xaf
 [<ffffffff803ab9a7>] sock_ioctl+0x1ed/0x21a
 [<ffffffff802b0473>] vfs_ioctl+0x2f/0x7c
 [<ffffffff802b0724>] do_vfs_ioctl+0x264/0x281
 [<ffffffff802b0788>] sys_ioctl+0x47/0x6b
 [<ffffffff803b7832>] ? dev_ioctl+0x34d/0x668
 [<ffffffff8020b4ab>] system_call_fastpath+0x16/0x1b

ADDRCONF(NETDEV_UP): eth0: link is not ready
tg3: eth0: Link is up at 100 Mbps, full duplex.
tg3: eth0: Flow control is on for TX and on for RX.
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
pci 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
eth0: no IPv6 routers present
