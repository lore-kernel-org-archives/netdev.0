From: Jovi Zhangwei <jovi@cloudflare.com>
Subject: Re: kernel warning in tcp_fragment
Date: Mon, 27 Jul 2015 12:08:34 -0700
Message-ID: <CABPcSq+sf0wfxVBMXQzhXymrb3+EMaUcBnkFZxXczpJSq4yZaQ@mail.gmail.com>
References: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Neal Cardwell <ncardwell@google.com>, kafai@fb.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:33490 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753291AbbG0TIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 15:08:36 -0400
Received: by lbbyj8 with SMTP id yj8so60012577lbb.0
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 12:08:34 -0700 (PDT)
In-Reply-To: <CABPcSqLrbCm92z23sSUf_0dLGZU5ZMHvzGxWkTxx0hH5KsBKQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping...

On Wed, Jul 22, 2015 at 11:55 AM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
> Hi Neal and Martin,
>
> Sorry for disturbing, our production system(3.14 and 3.18 stable
> kernel) have many tcp_fragment warnings,
> the trace is same as below one which you discussed before.
>
> http://comments.gmane.org/gmane.linux.network/365658
>
> But I didn't found the final solution in that mail thread, do you have
> any new ideas or patches on this warning?
>
> Great thanks.
>
>
> [5184217.672290] WARNING: CPU: 9 PID: 2801 at
> net/ipv4/tcp_output.c:1081 tcp_fragment+0x34/0x230()
> [5184217.680995] Modules linked in: sfc_char(O) sfc_resource(O)
> sfc_affinity(O) nf_conntrack_netlink xt_connlimit xt_length xt_bpf
> xt_hashlimit iptable_nat nf_nat_ipv4 nf_nat iptable_mangle xt_comment
> ip6table_security ip6table_mangle ip_set_hash_netport 8021q garp bridg
> e stp llc ipmi_devintf nf_conntrack_ipv6 nf_defrag_ipv6
> ip6table_filter ip6table_raw ip6_tables nf_conntrack_ipv4
> nf_defrag_ipv4 xt_NFLOG nfnetlink_log xt_conntrack iptable_filter
> xt_tcpudp xt_multiport xt_CT nf_conntrack xt_set iptable_raw ip_tables
> x_tables ip_set_hash
> _net ip_set_hash_ip ip_set nfnetlink rpcsec_gss_krb5 auth_rpcgss
> oid_registry nfsv4 fuse nfsv3 nfs_acl nfs fscache lockd sunrpc
> tcp_cubic sg sfc(O) mtd mdio igb dca i2c_algo_bit ptp pps_core sd_mod
> crct10dif_generic crc_t10dif crct10dif_common x86_pkg_temp_thermal
> acpi_c
> pufreq coretemp kvm_intel kvm crc32c_intel aesni_intel ablk_helper
> cryptd lrw gf128mul glue_helper aes_x86_64 ahci libahci ehci_pci
> libata ehci_hcd i2c_i801 i2c_core lpc_ich mfd_core usbcore scsi_mod
> usb_common wmi evdev ipmi_si ipmi_msghandler tpm_tis tpm acpi_pad
> proce
> ssor thermal_sys button
> [5184217.684098] CPU: 9 PID: 2801 Comm: rrdns Tainted: G        W  O
> 3.14.28-cloudflare #1
> [5184217.684099] Hardware name: Quanta Computer Inc QuantaPlex
> T41S-2U/S2S-MB, BIOS S2S_3A14          09/18/2014
> [5184217.684100]  0000000000000000 ffffffff81466263 0000000000000000
> ffffffff8103bb34
> [5184217.684101]  ffffffff813e07f2 ffff8818abebcc00 000000000000004a
> 0000000000000002
> [5184217.684102]  0000000000000060 ffffffff813e07f2 0000003000004120
> ffff8818abebcc00
> [5184217.684104] Call Trace:
> [5184217.684105]  <IRQ>  [<ffffffff81466263>] ? dump_stack+0x41/0x51
> [5184217.684111]  [<ffffffff8103bb34>] ? warn_slowpath_common+0x74/0x89
> [5184217.684115]  [<ffffffff813e07f2>] ? tcp_fragment+0x34/0x230
> [5184217.684118]  [<ffffffff813e07f2>] ? tcp_fragment+0x34/0x230
> [5184217.684119]  [<ffffffff813d98b7>] ? tcp_mark_head_lost+0x1bd/0x1d5
> [5184217.684123]  [<ffffffff813ddb71>] ? tcp_fastretrans_alert+0x69f/0x71d
> [5184217.684125]  [<ffffffff813de567>] ? tcp_ack+0x90f/0xb16
> [5184217.684126]  [<ffffffff813df618>] ? tcp_rcv_state_process+0x5bd/0x9b8
> [5184217.684128]  [<ffffffff8106d9c0>] ? __wake_up_sync_key+0x3a/0x4d
> [5184217.684130]  [<ffffffff813920ed>] ? sk_wake_async+0x17/0x34
> [5184217.684133]  [<ffffffff81440d13>] ? ipv6_skip_exthdr+0x28/0xc7
> [5184217.684139]  [<ffffffff81418db6>] ? NF_HOOK_THRESH.constprop.11+0x4a/0x4a
> [5184217.684143]  [<ffffffff81435abe>] ? tcp_v6_do_rcv+0x3ac/0x4f1
> [5184217.684146]  [<ffffffff81435eec>] ? tcp_v6_rcv+0x2e9/0x554
> [5184217.684148]  [<ffffffff813c70d3>] ? nf_hook_slow+0x66/0xf1
> [5184217.684150]  [<ffffffff81418db6>] ? NF_HOOK_THRESH.constprop.11+0x4a/0x4a
> [5184217.684167]  [<ffffffff81418f70>] ? ip6_input_finish+0x1ba/0x2a7
> [5184217.684169]  [<ffffffff813a1c12>] ? __netif_receive_skb_core+0x422/0x494
> [5184217.684172]  [<ffffffff813a283a>] ? netif_receive_skb_internal+0x37/0x6d
> [5184217.684188]  [<ffffffffa09a2e40>] ? efx_ssr_try_merge+0x336/0x34e [sfc]
> [5184217.684215]  [<ffffffffa09a4075>] ? __efx_ssr_end_of_burst+0x3e/0xd2 [sfc]
> [5184217.684225]  [<ffffffffa098e3bd>] ? efx_process_channel+0x5d/0x71 [sfc]
> [5184217.684243]  [<ffffffffa098f557>] ? efx_poll+0x6d/0x16b [sfc]
> [5184217.684248]  [<ffffffff813a2e27>] ? net_rx_action+0xc6/0x191
> [5184217.684250]  [<ffffffff8103f7ee>] ? __do_softirq+0x100/0x27c
> [5184217.684254]  [<ffffffff8103fae6>] ? irq_exit+0x51/0xbc
> [5184217.684255]  [<ffffffff81003e35>] ? do_IRQ+0x9d/0xb4
> [5184217.684258]  [<ffffffff8146992a>] ? common_interrupt+0x6a/0x6a
> [5184217.684261]  <EOI> <4>[5184217.684263] ---[ end trace 4f42d23abf1c890e ]---
> [5184217.684460] ------------[ cut here ]------------
