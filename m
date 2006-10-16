From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7366] New: BUG: unable to handle kernel paging
 request at virtual address d0cb03e0
Date: Sun, 15 Oct 2006 22:09:52 -0700
Message-ID: <20061015220952.08dde7b3.akpm@osdl.org>
References: <200610152100.k9FL0XCW014322@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, cristi@itz.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44437 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751464AbWJPFNT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 01:13:19 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200610152100.k9FL0XCW014322@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(plesae provide updates via reply-to-all email, not via the bugzilla
interface)

Looks like a netfilter regression.


On Sun, 15 Oct 2006 14:00:33 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7366
> 
>            Summary: BUG: unable to handle kernel paging request at virtual
>                     address d0cb03e0
>     Kernel Version: 2.6.19-rc2
>             Status: NEW
>           Severity: blocking
>              Owner: laforge@gnumonks.org
>          Submitter: cristi@itz.ro
> 
> 
> Most recent kernel where this bug did not occur:2.6.17.5
> Distribution: Mandriva 2007
> Hardware Environment: Mb chipset i810, CPU Celeron (Mendocino), Lan Cards 2xRTL8129
> Software Environment: Mandriva 2007, Test Kernel 2.6.19-rc2
> Problem Description: Kernel Locks when Entering comand "iptables -A INPUT -i
> eth1 -j ACCEPT" and this is the message in logs:
> ______________________________________________________________________________
> Oct 15 17:38:40 test kernel: BUG: unable to handle kernel paging request at
> virtual address d0cb03e0
> Oct 15 17:38:40 test kernel:  printing eip:
> Oct 15 17:38:40 test kernel: d08fc19b
> Oct 15 17:38:40 test kernel: *pde = 0ba03067
> Oct 15 17:38:40 test kernel: *pte = 00000000
> Oct 15 17:38:40 test kernel: Oops: 0000 [#1]
> Oct 15 17:38:40 test kernel: SMP
> Oct 15 17:38:40 test kernel: Modules linked in: ipt_MASQUERADE iptable_nat
> ip_nat ip_conntrack xt_limit ip6table_filter ip6_tables xt_mac xt_tcpudp
> xt_pkttype iptable_raw xt_CLASSIFY xt_MARK xt_length xt_physdev bridge xt_policy
> xt_multiport ipt_ULOG ipt_TTL ipt_ttl ipt_TOS ipt_tos ipt_TCPMSS ipt_REJECT
> ipt_recent ipt_owner ipt_LOG ipt_iprange ipt_ipp2p ipt_hashlimit ipt_ECN ipt_ecn
> ipt_CLUSTERIP ipt_ah ipt_addrtype nfnetlink iptable_mangle nfsd exportfs lockd
> nfs_acl ipv6 sunrpc iptable_filter ip_tables x_tables i810_audio ac97_codec
> soundcore 8139too mii af_packet ide_cd binfmt_misc loop dm_mod video thermal sbs
> processor i2c_ec i2c_core fan container button battery asus_acpi ac intel_agp
> agpgart uhci_hcd usbcore ext3 jbd
> Oct 15 17:38:40 test kernel: CPU:    0
> Oct 15 17:38:40 test kernel: EIP:    0060:[pg0+273219995/1069097984]    Not
> tainted VLI
> Oct 15 17:38:40 test kernel: EIP:    0060:[<d08fc19b>]    Not tainted VLI
> Oct 15 17:38:40 test kernel: EFLAGS: 00010282   (2.6.19-rc2-1 #2)
> Oct 15 17:38:40 test kernel: EIP is at xt_find_match+0x3b/0xf0 [x_tables]
> Oct 15 17:38:40 test kernel: eax: 00000000   ebx: d0cb03e0   ecx: 00000000  
> edx: cdcf7070
> Oct 15 17:38:40 test kernel: esi: d0cf5070   edi: 00000002   ebp: ca71fba0  
> esp: ca71fb8c
> Oct 15 17:38:40 test kernel: ds: 007b   es: 007b   ss: 0068
> Oct 15 17:38:40 test kernel: Process iptables (pid: 12607, ti=ca71e000
> task=cea9e560 task.ti=ca71e000)
> Oct 15 17:38:40 test kernel: Stack: 00000070 00cff000 d0cf5072 d0cf5070 00000002
> ca71fc18 d0b8db0e 00000002
> Oct 15 17:38:40 test kernel:        d0cf5072 00000000 ca71fbb8 ce88f248 00000163
> 000000d2 00000000 000000c0
> Oct 15 17:38:40 test kernel:        ccc95600 0000000e ca71fc80 00000000 ccc95600
> d0cf5000 ca71fbf8 d0cfe134
> Oct 15 17:38:40 test kernel: Call Trace:
> Oct 15 17:38:40 test kernel:  [show_trace_log_lvl+38/64]
> show_trace_log_lvl+0x26/0x40
> Oct 15 17:38:40 test kernel:  [<c0103fa6>] show_trace_log_lvl+0x26/0x40
> Oct 15 17:38:40 test kernel:  [show_stack_log_lvl+177/224]
> show_stack_log_lvl+0xb1/0xe0
> Oct 15 17:38:40 test kernel:  [<c0104071>] show_stack_log_lvl+0xb1/0xe0
> Oct 15 17:38:40 test kernel:  [show_registers+447/624] show_registers+0x1bf/0x270
> Oct 15 17:38:40 test kernel:  [<c010447f>] show_registers+0x1bf/0x270
> Oct 15 17:38:40 test kernel:  [die+313/752] die+0x139/0x2f0
> Oct 15 17:38:40 test kernel:  [<c0104669>] die+0x139/0x2f0
> Oct 15 17:38:40 test kernel:  [do_page_fault+545/1584] do_page_fault+0x221/0x630
> Oct 15 17:38:40 test kernel:  [<c011d351>] do_page_fault+0x221/0x630
> Oct 15 17:38:40 test kernel:  [error_code+57/64] error_code+0x39/0x40
> Oct 15 17:38:40 test kernel:  [<c0327641>] error_code+0x39/0x40
> Oct 15 17:38:40 test kernel:  [pg0+275913486/1069097984]
> translate_table+0x34e/0x880 [ip_tables]
> Oct 15 17:38:40 test kernel:  [<d0b8db0e>] translate_table+0x34e/0x880 [ip_tables]
> Oct 15 17:38:40 test kernel:  [pg0+275915230/1069097984]
> do_ipt_set_ctl+0x19e/0x770 [ip_tables]
> Oct 15 17:38:40 test kernel:  [<d0b8e1de>] do_ipt_set_ctl+0x19e/0x770 [ip_tables]
> Oct 15 17:38:40 test kernel:  [nf_sockopt+189/272] nf_sockopt+0xbd/0x110
> Oct 15 17:38:40 test kernel:  [<c02d7ecd>] nf_sockopt+0xbd/0x110
> Oct 15 17:38:40 test kernel:  [nf_setsockopt+41/48] nf_setsockopt+0x29/0x30
> Oct 15 17:38:40 test kernel:  [<c02d7f79>] nf_setsockopt+0x29/0x30
> Oct 15 17:38:40 test kernel:  [ip_setsockopt+314/3312] ip_setsockopt+0x13a/0xcf0
> Oct 15 17:38:40 test kernel:  [<c02e4b7a>] ip_setsockopt+0x13a/0xcf0
> Oct 15 17:38:40 test kernel:  [raw_setsockopt+58/144] raw_setsockopt+0x3a/0x90
> Oct 15 17:38:40 test kernel:  [<c02fe21a>] raw_setsockopt+0x3a/0x90
> Oct 15 17:38:40 test kernel:  [sock_common_setsockopt+49/64]
> sock_common_setsockopt+0x31/0x40
> Oct 15 17:38:40 test kernel:  [<c02b3151>] sock_common_setsockopt+0x31/0x40
> Oct 15 17:38:40 test kernel:  [sys_setsockopt+93/192] sys_setsockopt+0x5d/0xc0
> Oct 15 17:38:40 test kernel:  [<c02b133d>] sys_setsockopt+0x5d/0xc0
> Oct 15 17:38:40 test kernel:  [sys_socketcall+560/672] sys_socketcall+0x230/0x2a0
> Oct 15 17:38:40 test kernel:  [<c02b2c70>] sys_socketcall+0x230/0x2a0
> Oct 15 17:38:40 test kernel:  [sysenter_past_esp+86/121] sysenter_past_esp+0x56/0x79
> Oct 15 17:38:40 test kernel:  [<c0103285>] sysenter_past_esp+0x56/0x79
> Oct 15 17:38:40 test kernel:  =======================
> Oct 15 17:38:40 test kernel: Code: 45 10 88 45 f3 6b 45 08 38 89 45 ec 03 05 60
> e1 8f d0 e8 f9 a1 a2 ef 85 c0 0f 85 93 00 00 00 8b 55 ec 03 15 60 e1 8f d0 8b 5a
> 10 <8b> 03 8d 74 26 00 8d 42 10 31 c9 39 c3 75 23 e9 90 00 00 00 90
> Oct 15 17:38:40 test kernel: EIP: [pg0+273219995/1069097984]
> xt_find_match+0x3b/0xf0 [x_tables] SS:ESP 0068:ca71fb8c
> Oct 15 17:38:40 test kernel: EIP: [<d08fc19b>] xt_find_match+0x3b/0xf0
> [x_tables] SS:ESP 0068:ca71fb8c
> ________________________________________________________________________________
> 
> Steps to reproduce: Enter command "iptables -A INPUT -i eth1 -j ACCEPT"
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
