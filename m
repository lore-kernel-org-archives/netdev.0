From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: oops with 2.6.23.1, marvel, software raid, reiserfs and samba
Date: Sun, 16 Dec 2007 14:09:29 -0800
Message-ID: <20071216140929.694e82d1.akpm@linux-foundation.org>
References: <20071205151147.9db4640b.akpm@linux-foundation.org>
	<47573806.8000808@am.sony.com>
	<20071206142552.694B.Y-GOTO@jp.fujitsu.com>
	<475A0EF4.1020502@am.sony.com>
	<20071208035018.JENM21128.mta13.adelphia.net@dual-xeon.jeffunit.com>
	<20071216030516.1562a5d0.akpm@linux-foundation.org>
	<20071216145557.RTSZ20056.mta15.adelphia.net@dual-xeon.jeffunit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jeffunit <jeff@jeffunit.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33486 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752055AbXLPWJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 17:09:34 -0500
In-Reply-To: <20071216145557.RTSZ20056.mta15.adelphia.net@dual-xeon.jeffunit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Dec 2007 06:55:51 -0800 jeffunit <jeff@jeffunit.com> wrote:

> At 03:05 AM 12/16/2007, Andrew Morton wrote:
> >On Fri, 07 Dec 2007 19:49:52 -0800 jeffunit <jeff@jeffunit.com> wrote:
> >
> > > I am running linux kernel 2.6.23.1, which I compiled.
> > > The base system was mandriva 2008.
> > >
> > > I have a dual processor pentium III 933 system.
> > > It has 3gb of ram, an intel stl-2 motherboard.
> > > It also has a promise 100 tx2 pata controller,
> > > a supermicro marvell based 8 port pcix sata controller,
> > > and a nvidia pci based video card.
> > >
> > > I have the os on a pata drive, and have made a software raid array
> > > consisting of 4 sata drives attached to the pcix sata controller.
> > > I created the array, and formatted with reiserfs 3.6
> > > I have run bonnie++ (filesystem benchmark) on the array without incident.
> > > When I use samba-3.0.25b-4.3 and copy files from a windows machine to
> > > the fileserver,
> > > every so often, the fileserver crashes or hangs. It seems to happen
> > > more often under heavy samba traffic.
> > > Enclosed is the oops from syslog.
> > > I also have a 'kernel bug' from syslog if that would be helpful.
> > >
>
> ...
>
> >
> >(Please try to avoid the wordwrapping).

(you didn't)

> >That's a networking crash.  Do the oops traces which you're getting all look
> >like this one?
> >
> >Pentium III's are getting a bit old (resistive connections, drooping
> >power supplies, etc) so there's a decent chance that you're seeing
> >hardware failures here.
> 
> The other trace is a kernel bug. lt is included below.
> 
> It is true the hardware is a bit old, but I freshly assembled the system.
> The power supply is new, everything has been re-seated.
> I will be updating the hardware eventually, but I picked this hardware
> because it is low power (@120watts), server grade, has ecc memory,
> and has pcix- slots, which my ethernet card and 8 port sata controller need.
> 
> For what it is worth, the ethernet card is an intel  pro1000-mt.
> 
> Dec  3 15:44:50 sata_fileserver kernel: ------------[ cut here ]------------
> Dec  3 15:44:50 sata_fileserver kernel: Kernel BUG at c0167b30 
> [verbose debug info unavailable]

I'd suggest that you enable CONFIG_DEBUG_BUGVERBOSE, especially when the
system is having trouble.  It's worth it.

> Dec  3 15:44:50 sata_fileserver kernel: invalid opcode: 0000 [#1]
> Dec  3 15:44:51 sata_fileserver kernel: SMP
> Dec  3 15:44:51 sata_fileserver kernel: Modules linked in: 
> iptable_raw xt_comment xt_policy xt_multiport ipt_ULOG ipt_TTL 
> ipt_ttl ipt_TOS ipt_tos ipt_SAME ipt_REJECT ipt_REDIRECT ipt_recent 
> ipt_owner ipt_NETMAP ipt_MASQUERADE ipt_LOG ipt_iprange ipt_ECN 
> ipt_ecn ipt_CLUSTERIP ipt_ah ipt_addrtype nf_nat_tftp 
> nf_nat_snmp_basic nf_nat_sip nf_nat_pptp nf_nat_proto_gre nf_nat_irc 
> nf_nat_h323 nf_nat_ftp nf_nat_amanda ts_kmp nf_conntrack_amanda 
> nf_conntrack_tftp nf_conntrack_sip nf_conntrack_proto_sctp 
> nf_conntrack_pptp nf_conntrack_proto_gre nf_conntrack_netlink 
> nf_conntrack_netbios_ns nf_conntrack_irc nf_conntrack_h323 
> nf_conntrack_ftp xt_tcpmss xt_pkttype xt_physdev xt_NFQUEUE xt_NFLOG 
> xt_MARK xt_mark xt_mac xt_limit xt_length xt_helper xt_hashlimit 
> ip6_tables xt_dccp xt_conntrack xt_CONNMARK xt_connmark xt_CLASSIFY 
> xt_tcpudp nfsd xt_state iptable_nat nf_nat nf_conntrack_ipv4 exportfs 
> auth_rpcgss nf_conntrack iptable_mangle nfnetlink nfs lockd nfs_acl 
> sunrpc iptable_filter ip_tables x_tables af_packet ipv6 snd_seq_dummy snd_
> Dec  3 15:44:51 sata_fileserver kernel: eq_oss snd_seq_midi_event 
> snd_seq snd_pcm_oss snd_mixer_oss ipmi_si ipmi_msghandler binfmt_misc 
> loop nls_utf8 ntfs raid456 async_xor async_memcpy async_tx xor dm_mod 
> usb_storage sg sd_mod sata_mv libata scsi_mod video output thermal 
> sbs processor fan container button dock battery ac floppy snd_emu10k1 
> snd_rawmidi snd_ac97_codec ac97_bus snd_pcm ide_cd snd_seq_device 
> snd_timer snd_page_alloc i2c_piix4 snd_util_mem ohci_hcd uhci_hcd 
> i2c_core ehci_hcd snd_hwdep e1000 snd sworks_agp agpgart soundcore 
> usbcore emu10k1_gp gameport tsdev evdev reiserfs ide_disk serverworks 
> pdc202xx_new ide_core
> Dec  3 15:44:51 sata_fileserver kernel: CPU:    1
> Dec  3 15:44:51 sata_fileserver kernel: 
> EIP:    0060:[<c0167b30>]    Not tainted VLI
> Dec  3 15:44:51 sata_fileserver kernel: EFLAGS: 00210246   (2.6.23.1 #1)
> Dec  3 15:44:51 sata_fileserver kernel: EIP is at set_page_address+0x170/0x180
> Dec  3 15:44:51 sata_fileserver kernel: eax: ffbff000   ebx: 
> ffbff000   ecx: c0005ffc   edx: ffbff000
> Dec  3 15:44:51 sata_fileserver kernel: esi: c17d6c60   edi: 
> c0443ec0   ebp: ea139c88   esp: ea139c74
> Dec  3 15:44:51 sata_fileserver kernel: ds: 007b   es: 007b   fs: 
> 00d8  gs: 0033  ss: 0068
> Dec  3 15:44:52 sata_fileserver kernel: Process smbd (pid: 6132, 
> ti=ea138000 task=f139c000 task.ti=ea138000)
> Dec  3 15:44:52 sata_fileserver kernel: Stack: ffbff000 00200286 
> ffbff000 c17d6c60 3eb63163 ea139cb4 c0167ed2 ea139ca8
> Dec  3 15:44:52 sata_fileserver kernel:        ea138000 804cbe2c 
> 804cce2c ea139cac c0125248 c17d6c60 804cbe2c 804cce2c
> Dec  3 15:44:52 sata_fileserver kernel:        ea139cc0 c01209b0 
> 00000000 ea139cec f8aa86b5 0000000f 00000002 00000000
> Dec  3 15:44:52 sata_fileserver kernel: Call Trace:
> Dec  3 15:44:52 sata_fileserver kernel:  [<c010542a>] 
> show_trace_log_lvl+0x1a/0x30
> Dec  3 15:44:52 sata_fileserver kernel:  [<c01054eb>] 
> show_stack_log_lvl+0xab/0xd0
> Dec  3 15:44:52 sata_fileserver kernel:  [<c01056e1>] 
> show_registers+0x1d1/0x2d0
> Dec  3 15:44:52 sata_fileserver kernel:  [<c01058f6>] die+0x116/0x250
> Dec  3 15:44:53 sata_fileserver kernel:  [<c0105ac1>] do_trap+0x91/0xc0
> Dec  3 15:44:53 sata_fileserver kernel:  [<c0105dd8>] do_invalid_op+0x88/0xa0
> Dec  3 15:44:53 sata_fileserver kernel:  [<c030938a>] error_code+0x72/0x78
> Dec  3 15:44:53 sata_fileserver kernel:  [<c0167ed2>] kmap_high+0x152/0x1b0
> Dec  3 15:44:53 sata_fileserver kernel:  [<c01209b0>] kmap+0x50/0x80
> Dec  3 15:44:53 sata_fileserver kernel:  [<f8aa86b5>] 
> reiserfs_copy_from_user_to_file_region+0xa5/0xf0 [reiserfs]
> Dec  3 15:44:53 sata_fileserver kernel:  [<f8aa9c06>] 
> reiserfs_file_write+0x746/0x1dd0 [reiserfs]
> Dec  3 15:44:53 sata_fileserver kernel:  [<c017e2c5>] vfs_write+0xb5/0x140
> Dec  3 15:44:53 sata_fileserver kernel:  [<c017ea43>] sys_pwrite64+0x63/0x80
> Dec  3 15:44:54 sata_fileserver kernel:  [<c01042fe>] 
> sysenter_past_esp+0x6b/0xa1

This is a totally different crash and I don't think I've ever before seen a
crash in kmap()->set_page_address().  I'm suspecting hardware problems. 
Can you run memtest86 on that box for a day or so?

