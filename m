From: Michele Baldessari <michele-Vrs1pLNSz9odnm+yROfE0A@public.gmane.org>
Subject: WARNING: CPU: 0 PID: 3630 at net/core/dev.c:2218
 skb_warn_bad_offload+0xcd/0xda()
Date: Tue, 1 Apr 2014 21:18:30 +0100
Message-ID: <20140401201830.GA15519@marquez.int.rhx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi all,

in Fedora we've received a couple of reports of the above warning
(https://bugzilla.redhat.com/show_bug.cgi?id=1047693).

The trace looks as follows:
reporter:       libreport-2.1.10
WARNING: CPU: 0 PID: 3630 at net/core/dev.c:2218 skb_warn_bad_offload+0xcd/0xda()
: caps=(0x00000008801948c9, 0x0000000000000000) len=1898 data_len=1832
gso_size=1448 gso_type=5 ip_summed=0
Modules linked in: vhost_net vhost macvtap macvlan tun fuse
nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE bnep
bluetooth ip6t_REJECT xt_conntrack cfg80211 rfkill openvswitch vxlan
ip_tunnel gre libcrc32c ebtable_nat ebtable_broute bridge stp llc
ebtable_filter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6
nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw
ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4
nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security
iptable_raw snd_hda_codec_hdmi snd_hda_codec_realtek iTCO_wdt
iTCO_vendor_support x86_pkg_temp_thermal coretemp kvm_intel kvm
crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel joydev
hid_logitech_dj snd_hda_intel microcode snd_hda_codec snd_hwdep i2c_i801
snd_seq snd_seq_device snd_pcm snd_page_alloc snd_timer lpc_ich mfd_core
snd soundcore shpchp e1000e ptp pps_core mei_me mei tpm_tis tpm tpm_bios
nfsd auth_rpcgss nfs_acl lockd sunrpc raid1 i915 i2c_algo_bit
drm_kms_helper drm i2c_core video
CPU: 0 PID: 3630 Comm: vhost-3613 Not tainted 3.12.5-302.fc20.x86_64 #1
Hardware name:                  /DQ77KB, BIOS
KBQ7710H.86A.0052.2013.0708.1336 07/08/2013
 0000000000000009 ffff88041e203a10 ffffffff81662d11 ffff88041e203a58
 ffff88041e203a48 ffffffff810691dd ffff8803f39d6c00 ffff8803cf1b8000
 0000000000000005 0000000000000000 ffff8803f39d6c00 ffff88041e203aa8
Call Trace:
 <IRQ>  [<ffffffff81662d11>] dump_stack+0x45/0x56
 [<ffffffff810691dd>] warn_slowpath_common+0x7d/0xa0
 [<ffffffff8106924c>] warn_slowpath_fmt+0x4c/0x50
 [<ffffffff81308743>] ? ___ratelimit+0x93/0x100
 [<ffffffff816652a2>] skb_warn_bad_offload+0xcd/0xda
 [<ffffffff81566d01>] __skb_gso_segment+0x71/0xc0
 [<ffffffff8156700a>] dev_hard_start_xmit+0x18a/0x570
 [<ffffffff815859f0>] sch_direct_xmit+0xe0/0x1c0
 [<ffffffff815675e9>] dev_queue_xmit+0x1f9/0x4a0
 [<ffffffffa0507ecb>] netdev_send+0x4b/0xc0 [openvswitch]
 [<ffffffffa05033d2>] ? ovs_masked_flow_lookup+0x122/0x260 [openvswitch]
 [<ffffffffa050783d>] ovs_vport_send+0x1d/0x80 [openvswitch]
 [<ffffffffa04fe16a>] do_output+0x2a/0x50 [openvswitch]
 [<ffffffffa04fe613>] do_execute_actions+0x2e3/0xb20 [openvswitch]
 [<ffffffff810a43d2>] ? enqueue_task_fair+0x412/0x660
 [<ffffffffa04fee7b>] ovs_execute_actions+0x2b/0x30 [openvswitch]
 [<ffffffffa05022e8>] ovs_dp_process_received_packet+0x88/0x100 [openvswitch]
 [<ffffffff8109ab37>] ? try_to_wake_up+0xe7/0x290
 [<ffffffffa05077aa>] ovs_vport_receive+0x2a/0x30 [openvswitch]
 [<ffffffffa0508211>] netdev_frame_hook+0xc1/0x120 [openvswitch]
 [<ffffffff81565072>] __netif_receive_skb_core+0x252/0x820
 [<ffffffff81565658>] __netif_receive_skb+0x18/0x60
 [<ffffffff8156617e>] process_backlog+0xae/0x180
 [<ffffffff81565a49>] net_rx_action+0x149/0x240
 [<ffffffff8106e747>] __do_softirq+0xf7/0x240
 [<ffffffff8167361c>] call_softirq+0x1c/0x30
 <EOI>  [<ffffffff810146a5>] do_softirq+0x55/0x90
 [<ffffffff81564d58>] netif_rx_ni+0x28/0x30
 [<ffffffffa06236e1>] tun_get_user+0x401/0x820 [tun]
 [<ffffffffa0623b5a>] tun_sendmsg+0x5a/0x80 [tun]
 [<ffffffffa063dc9c>] handle_tx+0x1bc/0x530 [vhost_net]
 [<ffffffffa063e045>] handle_tx_kick+0x15/0x20 [vhost_net]
 [<ffffffffa062bdb2>] vhost_worker+0xf2/0x190 [vhost]
 [<ffffffffa062bcc0>] ? vhost_dev_reset_owner+0x30/0x30 [vhost]
 [<ffffffff8108b0d0>] kthread+0xc0/0xd0
 [<ffffffff8108b010>] ? insert_kthread_work+0x40/0x40
 [<ffffffff81671cbc>] ret_from_fork+0x7c/0xb0
 [<ffffffff8108b010>] ? insert_kthread_work+0x40/0x40

This has been reported also against 3.13 and 3.14 rc2 (I did not see any
commits after that which could address this, hence this mail).

In the above trace the two NICs of the system were:
# ethtool -i em1
driver: e1000e
version: 2.3.2-k
firmware-version: 2.1-3
bus-info: 0000:02:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
# ethtool -i em2
driver: e1000e
version: 2.3.2-k
firmware-version: 0.13-4
bus-info: 0000:00:19.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

# ethtool -k em1
Features for em1:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: off [fixed]
        tx-checksum-ip-generic: on
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
# ethtool -k em2
Features for em2:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: off [fixed]
        tx-checksum-ip-generic: on
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]
rx-fcs: off
rx-all: off
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]

thanks,
Michele
-- 
Michele Baldessari            <michele-Vrs1pLNSz9odnm+yROfE0A@public.gmane.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
