From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: kernel BUG at net/ipv6/exthdrs_core.c:80!
Date: Fri, 22 Apr 2005 14:32:59 +0300
Message-ID: <20050422113259.GX3858@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel is FC4 development series:

 2.6.11-1.1191_FC4smp #1 SMP
	Sun Mar 20 19:48:24 EST 2005 i686 i686 i386 GNU/Linux

and it reports following.
This isn't the first time it has done that either.

   /Matti Aarnio

kernel BUG at net/ipv6/exthdrs_core.c:80!
invalid operand: 0000 [#1]
SMP DEBUG_PAGEALLOC
Modules linked in: parport_pc lp parport w83627hf eeprom i2c_sensor i2c_isa ip_conntrack_ftp ipt_conntrack iptable_mangle ipt_state ip_conntrack ipt_REJECT iptable_filter ip_tables ip6table_filter ip6_tables md5 ipv6 dm_mod video button battery ac ohci1394 ieee1394 uhci_hcd ehci_hcd hw_random i2c_i801 i2c_core snd_intel8x0 snd_ac97_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc e100 mii sk98lin dummy floppy ext3 jbd raid1 sata_sil ata_piix libata aic7xxx sd_mod scsi_mod
CPU:    1
EIP:    0060:[<c0309611>]    Not tainted VLI
EFLAGS: 00010282   (2.6.11-1.1191_FC4smp) 
EIP is at ipv6_skip_exthdr+0xb0/0x15f
eax: fffffff2   ebx: 0000002c   ecx: f4ba0abe   edx: c5c3ef48
esi: 000000d8   edi: 00000000   ebp: 000000da   esp: f4ba0ab0
ds: 007b   es: 007b   ss: 0068
Process named (pid: 2498, threadinfo=f4ba0000 task=f4ba3ad0)
Stack: 00000002 f4ba0b17 c5c3ef48 80000000 c5c3ef48 00000028 f4ba0b58 00000000 
       c01bd46e 00000038 c9081080 001733f8 00000001 c2017c60 c2017c60 00000001 
       854830d2 f4ba3ad0 00000096 f4ba0afc f4ba0afc c0404488 00000001 f4ba0b2c 
Call Trace:
 [<c01bd46e>] selinux_parse_skb_ipv6+0x8a/0x14a
 [<c01bd58f>] selinux_parse_skb+0x61/0x8b
 [<c01be0fb>] selinux_ip_postroute_last+0xc9/0x222
 [<c01be299>] selinux_ipv6_postroute_last+0x20/0x25
 [<f8dca952>] ip6_output_finish+0x0/0xf0 [ipv6]
 [<c02b99e4>] nf_iterate+0x60/0x84
 [<f8dca952>] ip6_output_finish+0x0/0xf0 [ipv6]
 [<c02b9d32>] nf_hook_slow+0x4d/0xed
 [<f8dca952>] ip6_output_finish+0x0/0xf0 [ipv6]
 [<f8dca708>] ip6_output2+0x71/0x2bb [ipv6]
 [<f8dca952>] ip6_output_finish+0x0/0xf0 [ipv6]
 [<f8dccfa2>] dst_output+0x0/0x1f [ipv6]
 [<f8dcce05>] ip6_push_pending_frames+0x28f/0x42c [ipv6]
 [<f8dccfa2>] dst_output+0x0/0x1f [ipv6]
 [<c02ce5e0>] ip_generic_getfrag+0x0/0x94
 [<f8dddbfc>] udp_v6_push_pending_frames+0x124/0x1ac [ipv6]
 [<f8dde3bc>] udpv6_sendmsg+0x738/0x943 [ipv6]
 [<c02ace41>] skb_dequeue+0x4c/0x52
 [<f8ddcb25>] udpv6_recvmsg+0x9e/0x365 [ipv6]
 [<c02f1910>] inet_sendmsg+0x2e/0x4c
 [<c02a79ad>] sock_sendmsg+0xe4/0xff
 [<c014ac5f>] poison_obj+0x20/0x3d
 [<c014a71f>] dbg_redzone1+0x11/0x22
 [<c014c88c>] cache_alloc_debugcheck_after+0x35/0x16b
 [<c0134a1b>] autoremove_wake_function+0x0/0x37
 [<c014cca3>] kmem_cache_alloc+0x59/0x85
 [<c01b7d65>] avc_alloc_node+0x16/0x168
 [<c01b7d65>] avc_alloc_node+0x16/0x168
 [<c01d7602>] copy_from_user+0x42/0x80
 [<c02a925c>] sys_sendmsg+0x11e/0x213
 [<c011b689>] try_to_wake_up+0x6e/0x2b1
 [<c012642d>] current_fs_time+0x5a/0x75
 [<c017a77d>] inode_update_time+0x2d/0xa2
 [<c016da5b>] pipe_writev+0x432/0x4fd
 [<c02a9777>] sys_socketcall+0x24f/0x271
 [<c0103f31>] syscall_call+0x7/0xb
Code: 90 c7 04 24 02 00 00 00 8d 4c 24 0e 89 f2 8b 44 24 08 e8 c4 2e fa ff 31 ff 85 c0 78 0e 8d 7c 24 0e 89 f8 85 c0 0f 85 78 ff ff ff <0f> 0b 50 00 e6 93 34 c0 80 fb 2c 0f 85 70 ff ff ff 8b 54 24 08 
