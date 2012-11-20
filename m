From: "Rafal Kupka @ Telemetry" <rkupka@telemetry.com>
Subject: BUG: unable to handle kernel paging request at 0000000000609920 in
 networking code on 3.2.23.
Date: Tue, 20 Nov 2012 15:16:13 +0000
Message-ID: <A60E26F6-16DC-4A29-BFDE-1B17DC51F64F@telemetry.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange1.telemetry.com ([67.23.55.60]:64583 "EHLO
	exchange1.telemetry.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812Ab2KTPVg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 10:21:36 -0500
Content-Language: en-US
Content-ID: <417C003D823C2A4EA4C2F32C93C67A79@TELEMETRY.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

After upgrade to 3.2.23 (debian backports 2.6.32-45 package) from 2.6.32 I experience server crash.

[247494.043500] BUG: unable to handle kernel paging request at 0000000000609920
[247494.050663] IP: [<ffffffff810c6523>] put_page+0x4/0x27
[247494.056080] PGD 0
[247494.058221] Oops: 0000 [#1] SMP
[247494.061686] CPU 4
[247494.063720] Modules linked in: xt_multiport nf_defrag_ipv4 tcp_diag inet_diag xfrm_user xfrm4_tunnel ipcomp xfrm_ipcomp esp4 ah4 deflate zlib_deflate ctr twofish_generic twofish_x86_64_3way twofish_x86_64 twofish_common camellia serpent blowfish_generic blowfish_x86_64 blowfish_common cast5 des_generic cbc cryptd aes_x86_64 aes_generic xcbc rmd160 sha512_generic sha256_generic sha1_ssse3 sha1_generic hmac crypto_null af_key ipip tunnel4 ipt_ECN xt_TCPOPTSTRIP xt_tcpudp xt_comment iptable_mangle ip_tables x_tables loop i7core_edac edac_core snd_pcm snd_timer snd acpi_cpufreq mperf coretemp tpm_tis tpm tpm_bios i2c_i801 soundcore snd_page_alloc processor i2c_core psmouse pcspkr evdev thermal_sys serio_raw button crc32c_intel ext4 mbcache jbd2 crc16 dm_mod raid1 md_mod sd_mod crc_t10dif u
 sbhid hid ahci libahci libata ehci_hcd scsi_mod usbcore e1000e usb_common [last unloaded: nf_conntrack]
[247494.146444]
[247494.148120] Pid: 0, comm: swapper/4 Not tainted 3.2.0-0.bpo.3-amd64 #1 Supermicro X8SIE/X8SIE
[247494.156961] RIP: 0010:[<ffffffff810c6523>]  [<ffffffff810c6523>] put_page+0x4/0x27
[247494.164820] RSP: 0018:ffff88023fd03b40  EFLAGS: 00010282
[247494.170284] RAX: ffff8802340d5c80 RBX: ffff8801dcc6e680 RCX: 00000000219c3aab
[247494.177690] RDX: 0000000000000000 RSI: ffff8801ddea5bc0 RDI: 0000000000609920
[247494.185166] RBP: 0000000000000001 R08: ffff8801ddea5bc0 R09: ffff88023366c000
[247494.192640] R10: 00000001ddc550f6 R11: 0000000000000001 R12: ffff8802340d5c62
[247494.200028] R13: ffff8802340d5c62 R14: 0000000000000000 R15: ffff8802340d5c4e
[247494.207505] FS:  0000000000000000(0000) GS:ffff88023fd00000(0000) knlGS:0000000000000000
[247494.215936] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[247494.221824] CR2: 0000000000609920 CR3: 0000000001605000 CR4: 00000000000006e0
[247494.229220] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[247494.236617] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[247494.244093] Process swapper/4 (pid: 0, threadinfo ffff880236de2000, task ffff880236db88b0)
[247494.252609] Stack:
[247494.254732]  0000000100000000 ffffffff8129e5fa ffff8801dcc6e680 ffff8801dcc6e680
[247494.262482]  ffff8801dcc6e680 ffffffff8129ec02 ffff8801dd8b7240 ffffffff812e3a5b
[247494.270191]  000000003565d280 000000000002b80d ffffffffa025f4b8 ffff8801dcc6e680
[247494.277944] Call Trace:
[247494.280572]  <IRQ>
[247494.282807]  [<ffffffff8129e5fa>] ? skb_release_data+0x6c/0xe4
[247494.288923]  [<ffffffff8129ec02>] ? __kfree_skb+0x11/0x73
[247494.294475]  [<ffffffff812e3a5b>] ? tcp_rcv_state_process+0x74/0x8d9
[247494.301148]  [<ffffffff812eae9f>] ? tcp_v4_do_rcv+0x388/0x3eb
[247494.307081]  [<ffffffff812ec336>] ? tcp_v4_rcv+0x447/0x6ed
[247494.312676]  [<ffffffff812c95b6>] ? nf_hook_slow+0x68/0xfd
[247494.318382]  [<ffffffff812cf7ee>] ? T.1004+0x4f/0x4f
[247494.323458]  [<ffffffff81013a01>] ? read_tsc+0x5/0x16
[247494.328664]  [<ffffffff812cf92b>] ? ip_local_deliver_finish+0x13d/0x1aa
[247494.335468]  [<ffffffff812a8c1c>] ? __netif_receive_skb+0x44c/0x490
[247494.341873]  [<ffffffff81013a01>] ? read_tsc+0x5/0x16
[247494.347079]  [<ffffffff812a8ff7>] ? netif_receive_skb+0x67/0x6d
[247494.353171]  [<ffffffff812a9563>] ? napi_gro_receive+0x1f/0x2d
[247494.359166]  [<ffffffff812a90d1>] ? napi_skb_finish+0x1c/0x31
[247494.365032]  [<ffffffffa0049a17>] ? e1000_clean_rx_irq+0x1ea/0x29a [e1000e]
[247494.372133]  [<ffffffffa0049edb>] ? e1000_clean+0x71/0x229 [e1000e]
[247494.378551]  [<ffffffff812a9690>] ? net_rx_action+0xa8/0x207
[247494.384378]  [<ffffffff8104f1b6>] ? __do_softirq+0xc4/0x1a0
[247494.390105]  [<ffffffff81097ac9>] ? handle_irq_event_percpu+0x166/0x184
[247494.396886]  [<ffffffff81013a01>] ? read_tsc+0x5/0x16
[247494.402092]  [<ffffffff8136d4ec>] ? call_softirq+0x1c/0x30
[247494.407766]  [<ffffffff8100fa3f>] ? do_softirq+0x3f/0x79
[247494.413229]  [<ffffffff8104ef86>] ? irq_exit+0x44/0xb5
[247494.418522]  [<ffffffff8100f38a>] ? do_IRQ+0x94/0xaa
[247494.423686]  [<ffffffff81365f6e>] ? common_interrupt+0x6e/0x6e
[247494.429654]  <EOI>
[247494.431932]  [<ffffffff81200b2e>] ? intel_idle+0xdd/0x117
[247494.437476]  [<ffffffff81200b11>] ? intel_idle+0xc0/0x117
[247494.443031]  [<ffffffff812866ce>] ? cpuidle_idle_call+0xf9/0x1af
[247494.449205]  [<ffffffff8100dde2>] ? cpu_idle+0xaf/0xef
[247494.454509]  [<ffffffff81365c20>] ? _raw_spin_unlock_irqrestore+0xb/0x11
[247494.461377]  [<ffffffff8135e40e>] ? start_secondary+0x1db/0x1e1
[247494.467464] Code: 8b 47 1c f0 ff 4f 1c 0f 94 c0 84 c0 74 17 48 8b 07 f6 c4 40 74 06 5b e9 bb fe ff ff 48 89 df 5b e9 c5 fe ff ff 5b c3 48 83 ec 08 <66> f7 07 00 c0 74 06 59 e9 c6 fe ff ff 8b 47 1c f0 ff 4f 1c 0f
[247494.488128] RIP  [<ffffffff810c6523>] put_page+0x4/0x27
[247494.493523]  RSP <ffff88023fd03b40>
[247494.497117] CR2: 0000000000609920

Is that double-free issue somewhere in e1000e driver? What can be done to further pinpoint this bug?

This is unlikely to be RAM corruption or similar hardware issue because four different servers do experience this bug. All servers share Supermicro MB with e1000e [8086:10d3] NICs.

The time it takes to get to an oops seems to be network traffic related, more traffic means a crash occurs sooner.  A rough ballpark figure we see maybe one crash every 12 hours at 1MB/s and maybe a crash every four or so hours at 20MB/s.

When the traffic is very low (almost no packets) systems are "stable".

I tried to disable all possible NIC offloads (GRO too) but systems still crash. Same with loading e1000e module with InterruptThrottleRate=0.

Stack trace from http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=2eebc1e188e9e45886ee00662519849339884d6d looks very similar but it's in SCTP code.

Network configuration:
# The loopback network interface
auto lo
iface lo inet loopback
        up ip route add unreachable 91.217.135.0/24
        up ip addr  add 91.217.135.1/32 dev lo
        up ip addr  add 91.217.135.128/32 dev lo
        up sysctl -q -w net.ipv4.ip_forward=1
        up sysctl -q -w net.ipv4.conf.all.rp_filter=0

# The primary network interface
allow-hotplug eth1
iface eth1 inet static
        address 23.19.44.162
        netmask 255.255.255.248
        gateway 23.19.44.161

        up ip route change default via 23.19.44.161 dev eth1 initcwnd 10

        # we have to make TCP really dumb for our anycast subnet
        up ip route add default via 23.19.44.161 dev eth1 mtu lock 576 advmss $((576-40)) initcwnd 10 table anycast
        up ip rule add pref 16384 from 91.217.135.0/24 to 91.217.135.0/24 lookup main
        up ip rule add pref 16385 from 91.217.135.0/24 table anycast

# no need to worry about RPF for 91.217.135.0/24
auto tlm100-2
iface tlm100-2 inet static
        address 91.217.135.1
        netmask 255.255.255.255
        pointopoint 91.217.135.2
        mtu 576

        pre-up    ip tunnel add tlm100-2 mode ipip local 23.19.44.162 remote 23.19.43.42
        post-down ip tunnel del tlm100-2

** ip rule ls
0:      from all lookup local
16384:  from 91.217.135.0/24 to 91.217.135.0/24 lookup main
16385:  from 91.217.135.0/24 lookup anycast
32766:  from all lookup main
32767:  from all lookup default

** ip route ls table all
default via 23.19.44.161 dev eth1  table anycast  mtu lock 576 advmss 536 initcwnd 10
default via 23.19.44.161 dev eth1  initcwnd 10
23.19.44.160/29 dev eth1  proto kernel  scope link  src 23.19.44.162
unreachable 91.217.135.0/24
91.217.135.2 dev tlm100-2  proto kernel  scope link  src 91.217.135.1
broadcast 23.19.44.160 dev eth1  table local  proto kernel  scope link  src 23.19.44.162
local 23.19.44.162 dev eth1  table local  proto kernel  scope host  src 23.19.44.162
broadcast 23.19.44.167 dev eth1  table local  proto kernel  scope link  src 23.19.44.162
local 91.217.135.1 dev lo  table local  proto kernel  scope host  src 91.217.135.1
local 91.217.135.1 dev tlm100-2  table local  proto kernel  scope host  src 91.217.135.1
local 91.217.135.128 dev lo  table local  proto kernel  scope host  src 91.217.135.128
broadcast 127.0.0.0 dev lo  table local  proto kernel  scope link  src 127.0.0.1
local 127.0.0.0/8 dev lo  table local  proto kernel  scope host  src 127.0.0.1
local 127.0.0.1 dev lo  table local  proto kernel  scope host  src 127.0.0.1
broadcast 127.255.255.255 dev lo  table local  proto kernel  scope link  src 127.0.0.1

** Network status:
*** IP interfaces and addresses:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
   link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
   inet 127.0.0.1/8 scope host lo
   inet 91.217.135.1/32 scope global lo
   inet 91.217.135.128/32 scope global lo
   inet6 ::1/128 scope host
      valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
   link/ether 00:25:90:35:4d:aa brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
   link/ether 00:25:90:35:4d:ab brd ff:ff:ff:ff:ff:ff
   inet 23.19.44.162/29 brd 23.19.44.167 scope global eth1
   inet6 fe80::225:90ff:fe35:4dab/64 scope link
      valid_lft forever preferred_lft forever
4: tunl0: <NOARP> mtu 1480 qdisc noop state DOWN
   link/ipip 0.0.0.0 brd 0.0.0.0
5: tlm100-2: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 576 qdisc noqueue state UNKNOWN
   link/ipip 23.19.44.162 peer 23.19.43.42
   inet 91.217.135.1 peer 91.217.135.2/32 scope global tlm100-2

Iptables:

Chain INPUT (policy ACCEPT)
target     prot opt source               destination
dumbtcp    tcp  --  0.0.0.0/0            91.217.135.0/24

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination
dumbtcp    tcp  --  91.217.135.0/24      0.0.0.0/0

Chain dumbtcp (2 references)
target     prot opt source               destination
TCPOPTSTRIP  tcp  --  0.0.0.0/0            0.0.0.0/0            tcpflags: 0x02/0x02 TCPOPTSTRIP options 3,4,5,8,19
ECN        tcp  --  0.0.0.0/0            0.0.0.0/0            ECN TCP remove

Kind Regards,
Rafal Kupka

Rafal Kupka @ Telemetry
Infrastructure Engineer
Ext 118

London +44 207 148 7777
New York +1 212 380 6666

The digital media forensics company
