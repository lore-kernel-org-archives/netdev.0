From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: assertion (packets <= tp->packets_out) failed
Date: Sat, 1 Mar 2008 15:10:52 -0800
Message-ID: <2c0942db0803011510s5cfc30cbhee8ac9c1b849a2aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "kernel list" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759612AbYCAXLl@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wireless below is b43, wired interface (tg3) was disconnected. I run
openvpn which uses a tun interface and regularly sends a heartbeat
even when not in use. The trace appeared twice.

Likely unrelated but reporting just for completeness: about fifteen
minutes after this the system oopsed when I told my wireless base
station to switch from mixed B/G to just B. I'll be taking that up
separately with the bcm43xx list.

Mar  1 11:06:37 phoenix kernel: [35251.208275] eth1: switched to short
barker preamble (BSSID=00:16:01:d1:44:3e)
Mar  1 11:06:37 phoenix kernel: [35251.320282] eth1: switched to long
barker preamble (BSSID=00:16:01:d1:44:3e)
Mar  1 11:08:28 phoenix kernel: [35274.396163] KERNEL: assertion
(packets <= tp->packets_out) failed at net/ipv4/tcp_input.c (2139)
Mar  1 11:08:29 phoenix kernel: [35274.406126] ------------[ cut here
]------------
Mar  1 11:08:29 phoenix kernel: [35274.406132] WARNING: at
net/ipv4/tcp_input.c:2506 tcp_ack+0xe3f/0x1b12()
Mar  1 11:08:29 phoenix kernel: [35274.406134] Modules linked in: b43
mac80211 nls_iso8859_1 vfat fat usb_storage libusu
al tun nls_cp437 cifs af_packet rfcomm l2cap bluetooth binfmt_misc
radeon drm powernow_k8 cpufreq_stats iptable_filter i
p_tables x_tables dm_mod sbp2 snd_atiixp snd_atiixp_modem
snd_ac97_codec ac97_bus arc4 snd_pcm_oss ecb crypto_blkcipher
snd_pcm snd_mixer_oss snd_seq_dummy snd_seq_oss snd_seq_midi cfg80211
snd_rawmidi snd_seq_midi_event pcmcia led_class sn
d_seq snd_timer snd_seq_device sdhci serio_raw snd yenta_socket video
tifm_7xx1 rsrc_nonstatic evdev container output mm
c_core soundcore psmouse tifm_core pcmcia_core ssb battery ac button
pcspkr snd_page_alloc ext3 jbd mbcache ohci1394 sg
ieee1394 tg3 sr_mod cdrom sd_mod ehci_hcd ohci_hcd ata_generic usbcore
thermal processor fan fuse [last unloaded: mac80211]
Mar  1 11:08:29 phoenix kernel: [35274.406162] Pid: 5095, comm:
openvpn Tainted: G   M    2.6.24 #12
Mar  1 11:08:29 phoenix kernel: [35274.406162]
Mar  1 11:08:29 phoenix kernel: [35274.406162] Call Trace:
Mar  1 11:08:29 phoenix kernel: [35274.406162]  <IRQ>
[ext3:warn_on_slowpath+0x58/0x277] warn_on_slowpath+0x58/0x6b
Mar  1 11:08:29 phoenix kernel: [35274.406162]
[discard_slab+0x30/0x32] ? discard_slab+0x30/0x32
Mar  1 11:08:29 phoenix kernel: [35274.406162]
[__slab_free+0xd0/0x357] ? __slab_free+0xd0/0x357
Mar  1 11:08:29 phoenix kernel: [35274.406162]
[skb_release_data+0xa7/0xac] ? skb_release_data+0xa7/0xac
Mar  1 11:08:29 phoenix kernel: [35274.406162]
[tcp_rtt_estimator+0xf2/0x142] ? tcp_rtt_estimator+0xf2/0x142
Mar  1 11:08:29 phoenix kernel: [35274.406162]  [tcp_ack+0xe3f/0x1b12]
tcp_ack+0xe3f/0x1b12
Mar  1 11:08:29 phoenix kernel: [35274.406162]
[tcp_rcv_established+0x602/0x712] tcp_rcv_established+0x602/0x712
Mar  1 11:08:29 phoenix kernel: [35274.406169]
[tcp_v4_do_rcv+0x31/0x1c8] tcp_v4_do_rcv+0x31/0x1c8
Mar  1 11:08:29 phoenix kernel: [35274.406176]
[tcp_v4_rcv+0x68c/0x6e9] tcp_v4_rcv+0x68c/0x6e9
Mar  1 11:08:29 phoenix kernel: [35274.406184]
[ip_local_deliver_finish+0x135/0x1c4]
ip_local_deliver_finish+0x135/0x1c4
Mar  1 11:08:29 phoenix kernel: [35274.406189]
[ip_local_deliver+0x72/0x7c] ip_local_deliver+0x72/0x7c
Mar  1 11:08:29 phoenix kernel: [35274.406194]
[ip_rcv_finish+0x296/0x2bb] ip_rcv_finish+0x296/0x2bb
Mar  1 11:08:29 phoenix kernel: [35274.406198]
[tg3:netif_receive_skb+0x3c0/0x5f7] ? netif_receive_skb+0x3c0/0x3e2
Mar  1 11:08:29 phoenix kernel: [35274.406205]  [ip_rcv+0x22e/0x250]
ip_rcv+0x22e/0x250
Mar  1 11:08:29 phoenix kernel: [35274.406208]
[process_backlog+0xd3/0xfc] ? process_backlog+0xd3/0xfc
Mar  1 11:08:29 phoenix kernel: [35274.406213]
[tg3:netif_receive_skb+0x3a8/0x5f7] netif_receive_skb+0x3a8/0x3e2
Mar  1 11:08:29 phoenix kernel: [35274.406220]
[process_backlog+0x94/0xfc] process_backlog+0x94/0xfc
Mar  1 11:08:29 phoenix kernel: [35274.406226]
[net_rx_action+0xab/0x1a1] net_rx_action+0xab/0x1a1
Mar  1 11:08:29 phoenix kernel: [35274.406233]
[__do_softirq+0x67/0xc9] __do_softirq+0x67/0xc9
Mar  1 11:08:29 phoenix kernel: [35274.406239]
[call_softirq+0x1c/0x28] call_softirq+0x1c/0x28
Mar  1 11:08:29 phoenix kernel: [35274.406241]  <EOI>
[do_softirq+0x4d/0xb0] do_softirq+0x4d/0xb0
Mar  1 11:08:29 phoenix kernel: [35274.406248]
[netif_rx_ni+0x31/0x58] netif_rx_ni+0x31/0x58
Mar  1 11:08:29 phoenix kernel: [35274.406255]  [<ffffffff88368ce1>]
:tun:tun_chr_aio_write+0x1e5/0x22c
Mar  1 11:08:29 phoenix kernel: [35274.406266]
[ext3:do_sync_write+0xeb/0x132] do_sync_write+0xeb/0x132
Mar  1 11:08:29 phoenix kernel: [35274.406277]  [<ffffffff8023eda5>] ?
autoremove_wake_function+0x0/0x38
Mar  1 11:08:29 phoenix kernel: [35274.406281]
[sys_recvfrom+0xc8/0xf5] ? sys_recvfrom+0xc8/0xf5
Mar  1 11:08:29 phoenix kernel: [35274.406297]  [vfs_write+0xae/0x157]
vfs_write+0xae/0x157
Mar  1 11:08:29 phoenix kernel: [35274.406303]  [sys_write+0x47/0x70]
sys_write+0x47/0x70
Mar  1 11:08:29 phoenix kernel: [35274.406310]
[system_call_after_swapgs+0x8a/0x8f]
system_call_after_swapgs+0x8a/0x8f
Mar  1 11:08:29 phoenix kernel: [35274.406319]
Mar  1 11:08:29 phoenix kernel: [35274.406321] ---[ end trace
1bac8d9854a4a52e ]---
