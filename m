From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 0/6] Use ctl paths in the networking code.
Date: Tue, 08 Jan 2008 18:52:16 +0300
Message-ID: <47839C30.2040402@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40662 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760408AbYAHPwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 10:52:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set almost completes the ctl paths usage in the 
networking code. The first patches doing this were accepted 
in the last year :), but they tuned only core, ipv4 and ipv6.

I thought, that splitting this into many subsystem would
produce too many patches, so I splitted it so, that most 
subsystems that are patched in a very similar way are 
merged into one patch to make the review easier. Hope this 
is OK.

After this set the vmlinux size becomes almost 4Kb less (when
all patched files are built-in):

add/remove: 16/40 grow/shrink: 18/6 up/down: 486/-4394 (-3908)
function                                     old     new   delta
net_vs_ctl_path                                -      32     +32
dccp_path                                      -      32     +32
x25_path                                       -      24     +24
sctp_path                                      -      24     +24
rose_path                                      -      24     +24
nr_path                                        -      24     +24
net_ipv6_ctl_path                              -      24     +24
net_ipv4_ctl_path                              -      24     +24
llc_path                                       -      24     +24
irda_path                                      -      24     +24
ipx_path                                       -      24     +24
dn_path                                        -      24     +24
brnf_path                                      -      24     +24
ax25_path                                      -      24     +24
atalk_path                                     -      24     +24
nf_ct_path                                     -      16     +16
dn_dev_sysctl_register                       164     173      +9
x25_register_sysctl                           16      21      +5
sctp_sysctl_register                          16      21      +5
rose_register_sysctl                          16      21      +5
nr_register_sysctl                            16      21      +5
nf_conntrack_standalone_init                 166     171      +5
llc_sysctl_init                               24      29      +5
irda_sysctl_register                          24      29      +5
ipx_register_sysctl                           16      21      +5
ip_vs_lblcr_init                              66      71      +5
ip_vs_control_init                           209     214      +5
ip_queue_init                                288     293      +5
ip6_queue_init                               288     293      +5
dn_register_sysctl                            16      21      +5
dccp_sysctl_init                              24      29      +5
br_netfilter_init                             91      96      +5
atalk_register_sysctl                         16      21      +5
ax25_register_sysctl                         294     290      -4
ax25_unregister_sysctl                        56      46     -10
nf_unregister_sysctl_table                    19       -     -19
net_ipv4_path                                 48      24     -24
ipv6_ctl_path                                 24       -     -24
path_free                                     27       -     -27
nf_net_ipv4_netfilter_sysctl_path             88      32     -56
nf_net_netfilter_sysctl_path                  88      24     -64
x25_root_table                                88       -     -88
x25_dir_table                                 88       -     -88
vs_root_table                                 88       -     -88
sctp_root_table                               88       -     -88
sctp_net_table                                88       -     -88
rose_root_table                               88       -     -88
rose_dir_table                                88       -     -88
nr_root_table                                 88       -     -88
nr_dir_table                                  88       -     -88
nf_net_netfilter_table                        88       -     -88
nf_net_ipv4_table                             88       -     -88
nf_net_ipv4_netfilter_table                   88       -     -88
nf_ct_net_table                               88       -     -88
llc_root_table                                88       -     -88
llc_dir_table                                 88       -     -88
lblcr_root_table                              88       -     -88
lblc_root_table                               88       -     -88
irda_root_table                               88       -     -88
irda_net_table                                88       -     -88
ipx_root_table                                88       -     -88
ipx_dir_table                                 88       -     -88
dn_root_table                                 88       -     -88
dn_dir_table                                  88       -     -88
dccp_table                                    88       -     -88
dccp_root_table                               88       -     -88
dccp_dir_table                                88       -     -88
brnf_net_table                                88       -     -88
brnf_bridge_table                             88       -     -88
ax25_root_table                               88       -     -88
ax25_dir_table                                88       -     -88
atalk_root_table                              88       -     -88
atalk_dir_table                               88       -     -88
nf_register_sysctl_table                     118       -    -118
ipq_root_table                               176       -    -176
ipq_dir_table                                176       -    -176
vs_table                                     264       -    -264
ipvs_ipv4_table                              264       -    -264
dn_dev_sysctl                                576     224    -352

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
