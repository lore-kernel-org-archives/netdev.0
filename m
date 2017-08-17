From: Nick Huber <nick.huber@multapplied.net>
Subject: skb_over_panic when sending esp traffic from a vmware guest
Date: Thu, 17 Aug 2017 19:19:03 +0000
Message-ID: <CY1PR17MB0552F3C75C45DBC72799A0F187830@CY1PR17MB0552.namprd17.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0043.outbound.protection.outlook.com ([104.47.42.43]:28832
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753326AbdHQTTG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 15:19:06 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been experience the following traceback since upgrading from the 4.9 k=
ernel to the 4.11 branch. I've only seen this in a few VMWare guests and I =
haven't been able to narrow down what exactly is causing it. I'm not famili=
ar with kernel debugging but any help in tracing this down would be appreci=
ated.

skbuff: skb_over_panic: text:ffffffff8a53e2a7 len:464 put:4 head:ffff904d76=
82b400 data:ffff904d7682b4f4 tail:0x2c4 end:0x2c0 dev:chwk-pwr186
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:105!
invalid opcode: 0000 [#1] SMP
Modules linked in: sch_sfq xt_TEE nf_dup_ipv6 nf_dup_ipv4 xt_set ip_set_has=
h_net ip_set nfnetlink xt_socket nf_socket_ipv4 nf_socket_ipv6 xt_REDIRECT =
nf_nat_redirect sch_htb sit tunnel4 veth drbg ansi_cprng authenc seqiv esp4=
 xfrm4_mode_transport binfmt_misc xt_connbytes xt_hashlimit xt_dscp xt_CLAS=
SIFY xt_length xt_TCPMSS iptable_raw xt_nat xt_connmark xt_mark iptable_nat=
 nf_nat_ipv4 iptable_mangle netconsole ip6t_REJECT nf_reject_ipv6 ipt_REJEC=
T nf_reject_ipv4 nf_conntrack_ipv6 nf_defrag_ipv6 nf_conntrack_ipv4 nf_defr=
ag_ipv4 xt_conntrack xt_comment ip6table_filter ip6_tables xt_multiport xt_=
tcpudp arptable_filter arp_tables iptable_filter ip_tables x_tables configf=
s mptctl nfsd auth_rpcgss nfs_acl nfs lockd grace fscache sunrpc sb_edac ed=
ac_core coretemp crct10dif_pclmul crc32_pclmul
 ghash_clmulni_intel deflate pcbc evdev ppdev snd_pcm snd_timer vmw_balloon=
 aesni_intel snd serio_raw soundcore pcspkr ctr aes_x86_64 crypto_simd twof=
ish_generic twofish_avx_x86_64 twofish_x86_64_3way twofish_x86_64 twofish_c=
ommon sg camellia_generic battery camellia_aesni_avx_x86_64 camellia_x86_64=
 vmwgfx parport_pc ttm parport serpent_avx_x86_64 shpchp drm_kms_helper drm=
 vmw_vmci serpent_sse2_x86_64 xts serpent_generic lrw gf128mul glue_helper =
ac button blowfish_generic blowfish_x86_64 blowfish_common cast5_avx_x86_64=
 cast5_generic cast_common ablk_helper cryptd des_generic cbc cmac xcbc rmd=
160 sha512_ssse3 sha512_generic af_key xfrm_algo loop nf_nat_pptp nf_nat_pr=
oto_gre nf_nat_ftp nf_nat nf_conntrack_pptp nf_conntrack_proto_gre nf_connt=
rack_ftp nf_conntrack libcrc32c crc32c_generic
 ip_gre ip_tunnel gre 8021q garp mrp stp llc tun autofs4 ext4 crc16 jbd2 fs=
crypto mbcache sr_mod cdrom sd_mod ata_generic crc32c_intel psmouse ata_pii=
x mptspi scsi_transport_spi mptscsih vmxnet3 mptbase i2c_piix4 libata scsi_=
mod floppy [last unloaded: netconsole]
CPU: 3 PID: 2365 Comm: bridge Not tainted 4.11.12 #2
Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference=
 Platform, BIOS 6.00 04/14/2014
task: ffff904d76efa040 task.stack: ffffb92fc0d60000
RIP: 0010:skb_panic+0x51/0x60
RSP: 0018:ffffb92fc0d63658 EFLAGS: 00010292
RAX: 000000000000008c RBX: ffff904d7a331800 RCX: 0000000000000000
RDX: ffff904d7fd95e28 RSI: ffff904d7fd8df88 RDI: ffff904d7fd8df88
RBP: ffffb92fc0d63678 R08: 0000000135219082 R09: 0000000000000585
R10: 0000000000000004 R11: 3039666666663a64 R12: 0000000000000001
R13: ffff904d786f8480 R14: ffff904d75b87a00 R15: ffff904d7682b4e4
FS:  00007fc0a42c1700(0000) GS:ffff904d7fd80000(0000) knlGS:000000000000000=
0
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007f5173a8a8b0 CR3: 0000000136471000 CR4: 00000000000406e0
Call Trace:
 skb_put+0x4d/0x50
 pskb_put+0x27/0x30
 esp_output+0x1e7/0xace [esp4]
 ? ip_finish_output+0x180/0x280
 xfrm_output_resume+0x13c/0x390
 ? xfrm_output+0x82/0xe0
 ? skb_release_all+0x24/0x30
 xfrm_output+0xb3/0xe0
 xfrm4_output_finish+0x2b/0x30
 __xfrm4_output+0x34/0x40
 xfrm4_output+0x40/0xa0
 ? xfrm4_udp_encap_rcv+0x1b0/0x1b0
 ip_local_out+0x35/0x40
 iptunnel_xmit+0x13d/0x1b0
 ip_tunnel_xmit+0x388/0x14b0 [ip_tunnel]
 __gre_xmit+0x174/0x210 [ip_gre]
 ipgre_xmit+0x1d4/0x220 [ip_gre]
 dev_hard_start_xmit+0xa1/0x200
 __dev_queue_xmit+0x595/0x670
 dev_queue_xmit+0x10/0x20
 neigh_direct_output+0x11/0x20
 ip_finish_output2+0x16b/0x360
 ip_finish_output+0x180/0x280
 ip_output+0x67/0xd0
 ? ip_fragment.constprop.49+0x80/0x80
 ip_local_out+0x35/0x40
 ip_queue_xmit+0x158/0x3e0
 ? tcp_v4_md5_lookup+0x13/0x20
 tcp_transmit_skb+0x56d/0x950
 tcp_write_xmit+0x191/0xf40
 __tcp_push_pending_frames+0x31/0xd0
 tcp_push+0xef/0x120
 tcp_sendmsg+0x432/0xbf0
 inet_sendmsg+0x31/0xb0
 sock_sendmsg+0x38/0x50
 SYSC_sendto+0xef/0x170
 SyS_sendto+0xe/0x10
 entry_SYSCALL_64_fastpath+0x1e/0xad
RIP: 0033:0x7fc0a3967ead
RSP: 002b:00007fff42176488 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 00007fc09c2fdc48 RCX: 00007fc0a3967ead
RDX: 000000000000070a RSI: 0000000002452bd0 RDI: 0000000000000048
RBP: 00007fc09c3948b8 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007fc09f01e5c0
R13: 0000000000000000 R14: 00007fc09c3948b8 R15: 00007fc0a3c03b40
Code: 00 50 8b 87 cc 00 00 00 50 8b 87 c8 00 00 00 50 ff b7 d8 00 00 00 31 =
c0 4c 8b 8f d0 00 00 00 48 c7 c7 e8 b0 a3 8a e8 d5 97 c5 ff <0f> 0b 66 66 6=
6 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48=20
RIP: skb_panic+0x51/0x60 RSP: ffffb92fc0d63658
