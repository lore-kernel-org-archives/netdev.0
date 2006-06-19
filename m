From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6681] New: TC crash and rule freeze
Date: Mon, 19 Jun 2006 15:21:45 -0700
Message-ID: <20060619152145.3defd8f0.akpm@osdl.org>
References: <200606121733.k5CHX9rn022476@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: slavon@bigtelecom.ru,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20418 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964954AbWFSWSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2006 18:18:44 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200606121733.k5CHX9rn022476@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bugme-daemon@bugzilla.kernel.org wrote:
>
> http://bugzilla.kernel.org/show_bug.cgi?id=6681
> 
>            Summary: TC crash and rule freeze
>     Kernel Version: 2.6.16-gentoo-r6
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: slavon@bigtelecom.ru
> 
> 
> Most recent kernel where this bug did not occur:
> 2.6.16-gentoo-r6
> Distribution:
> Gentoo
> Hardware Environment:
> 00:00.0 Host bridge: Intel Corporation 82865G/PE/P DRAM Controller/Host-Hub
> Interface (rev 02)
> 00:02.0 VGA compatible controller: Intel Corporation 82865G Integrated Graphics
> Controller (rev 02)
> 00:1d.0 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI
> Controller #1 (rev 02)
> 00:1d.1 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI
> Controller #2 (rev 02)
> 00:1d.2 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI
> Controller #3 (rev 02)
> 00:1d.3 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB UHCI
> Controller #4 (rev 02)
> 00:1d.7 USB Controller: Intel Corporation 82801EB/ER (ICH5/ICH5R) USB2 EHCI
> Controller (rev 02)
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev c2)
> 00:1f.0 ISA bridge: Intel Corporation 82801EB/ER (ICH5/ICH5R) LPC Interface
> Bridge (rev 02)
> 00:1f.1 IDE interface: Intel Corporation 82801EB/ER (ICH5/ICH5R) IDE Controller
> (rev 02)
> 01:09.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet Pro 100] (rev 05)
> 01:0a.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet Pro 100] (rev 05)
> 01:0b.0 SCSI storage controller: Adaptec ASC-39320 U320 (rev 03)
> 01:0b.1 SCSI storage controller: Adaptec ASC-39320 U320 (rev 03)
> Software Environment:
> sys-apps/iproute2-2.6.16.20060323
> Problem Description:
> #cat dmeseg
> Unable to handle kernel NULL pointer dereference at virtual address 0000000c
> printing eip:
> c0217c26
> *pde = 00000000
> Oops: 0000 [#1]
> SMP
> Modules linked in: sch_sfq cls_u32 sch_red sch_htb iptable_filter ip_tables
> x_tables uhci_hcd ehci_hcd usbcore
> CPU:    0
> EIP:    0060:[<c0217c26>]    Not tainted VLI
> EFLAGS: 00010287   (2.6.16-gentoo-r6 #2)
> EIP is at __rb_erase_color+0x94/0x1ad
> eax: f55f4954   ebx: f724bb54   ecx: f724bb54   edx: 00000000
> esi: 00000000   edi: f7679468   ebp: f7679468   esp: f676bbbc
> ds: 007b   es: 007b   ss: 0068
> Process tc (pid: 24294, threadinfo=f676a000 task=f7d7da90)
> Stack: <0>f724bb54 f7679468 00000000 e6bbf154 00000000 c0217e36 00000000 f724bb54
> f7679468 e6bbf000 e6bbf06c f7679000 f7679080 f8903366 e6bbf154 f7679468
> 00000004 000000d0 00000000 00010006 000103c9 f7679000 c0311ffa f7679000
> Call Trace:
> [<c0217e36>] rb_erase+0xf7/0x12d
> [<f8903366>] htb_destroy_class+0xec/0x15d [sch_htb]
> [<c0311ffa>] tc_ctl_tclass+0x1b1/0x288
> [<c030d69e>] rtnetlink_dump_ifinfo+0x6c/0x89
> [<c030dcef>] rtnetlink_rcv_msg+0x171/0x233
> [<c031759f>] netlink_dump+0x94/0x1e2
> [<c030db7e>] rtnetlink_rcv_msg+0x0/0x233
> [<c0317a45>] netlink_rcv_skb+0x46/0xad
> [<c030db7e>] rtnetlink_rcv_msg+0x0/0x233
> [<c0317aec>] netlink_run_queue+0x40/0xd0
> [<c030db7e>] rtnetlink_rcv_msg+0x0/0x233
> [<c030db5e>] rtnetlink_rcv+0x2e/0x4e
> [<c030db7e>] rtnetlink_rcv_msg+0x0/0x233
> [<c031735c>] netlink_data_ready+0x60/0x62
> [<c03164ed>] netlink_sendskb+0x32/0x61
> [<c031704d>] netlink_sendmsg+0x291/0x304
> [<c02f9b0d>] sock_sendmsg+0xeb/0x10d
> [<c02f9b0d>] sock_sendmsg+0xeb/0x10d
> [<c0131fa6>] autoremove_wake_function+0x0/0x57
> [<c021a084>] copy_from_user+0x46/0x7e
> [<c0300ae4>] verify_iovec+0x44/0x9e
> [<c02fb525>] sys_sendmsg+0x15a/0x272
> [<c0140ca6>] filemap_nopage+0x30d/0x38a
> [<c0152e83>] page_add_file_rmap+0x2a/0x2e
> [<c014e014>] do_no_page+0x219/0x278
> [<c021a084>] copy_from_user+0x46/0x7e
> [<c02fbaf7>] sys_socketcall+0x28d/0x294
> [<c0102ca7>] sysenter_past_esp+0x54/0x75
> Code: 04 01 00 00 00 c7 43 04 00 00 00 00 89 7c 24 04 89 1c 24 e8 6b fe ff ff 8b
> 53 0c eb 8e 8b 53 08 8b 72 04 85 f6 0f 84 82 00 00 00  <8b> 4a 0c 85 c9 74 0a 83
> 79 04 01 0f 85 00 01 00 00 8b 72 08 85
> 

It crashed in net/sched/somewhere.
