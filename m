From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 9 Jan 2007 22:05:11 +0100
Message-ID: <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com>
	 <20070109092602.GC1703@ff.dom.local>
	 <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
	 <20070109130220.GA4060@ff.dom.local>
	 <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com>
	 <20070109200541.GA27089@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:65507 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932448AbXAIVFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 16:05:13 -0500
Received: by nf-out-0910.google.com with SMTP id o25so261818nfa
        for <netdev@vger.kernel.org>; Tue, 09 Jan 2007 13:05:11 -0800 (PST)
To: "Dale Farnsworth" <dale@farnsworth.org>
In-Reply-To: <20070109200541.GA27089@xyzzy.farnsworth.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/9/07, Dale Farnsworth <dale@farnsworth.org> wrote:
> On Tue, Jan 09, 2007 at 06:44:49PM +0100, Thibaut VARENE wrote:
> > On 1/9/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> > >On Tue, Jan 09, 2007 at 11:27:59AM +0100, Thibaut VARENE wrote:
> > >...
> > >> I suspected both and changed both the disk and the ram for quality
> > >> parts, that I tested afterwards. Both passed thorough tests.
> > >>
> > >> Finally, using the other NIC on the box (a VIA Rhine II, 100Mbps),
> > >> works absolutely fine.
> > >
> > >If you are not tired, I'd suggest two more tests:
> >
> > I volunteered to help :)
>
> Thank you Thibaut.  Please try the following patch:
>
> From: Dale Farnsworth <dale@farnsworth.org>
>
> Reserve one unused descriptor in the TX ring
> to facilitate testing for when the ring is full.

Dale,

tried it and unfortunately:

Alucard login: ------------[ cut here ]------------
kernel BUG at drivers/net/mv643xx_eth.c:1071!
Oops: Exception in kernel mode, sig: 5 [#1]
PREEMPT
Modules linked in: eeprom sbp2 scsi_mod eth1394 uhci_hcd vt8231 ohci1394 ieee13t
NIP: C0210B40 LR: C02126DC CTR: C0212620
REGS: dd2d7b40 TRAP: 0700   Not tainted  (2.6.20-rc4)
MSR: 00021032 <ME,IR,DR>  CR: 28242488  XER: 00000000
TASK = da03c640[1775] 'ncftp' THREAD: dd2d6000
GPR00: 00000000 DD2D7BF0 DA03C640 CFB16260 CFB16000 0000000B DF79FDD2 00000000
GPR08: 00000BA9 00000001 00001000 00000BAA 28242482 10056CD0 28004422 C03D9BF8
GPR16: 00000000 00000000 00000000 DD2D6000 00000001 CFB162BC 00009032 00000000
GPR24: 000005A8 00000000 C03E0000 CFB16000 C0212620 CFCB3260 CFB16260 DF79FDA0
NIP [C0210B40] eth_alloc_tx_desc_index+0x44/0x50
LR [C02126DC] mv643xx_eth_start_xmit+0xbc/0x3b8
Call Trace:
[DD2D7BF0] [DF79FDD0] 0xdf79fdd0 (unreliable)
[DD2D7C30] [C029F258] dev_hard_start_xmit+0x1d4/0x2c8
[DD2D7C50] [C02A1BF4] dev_queue_xmit+0x2bc/0x334
[DD2D7C70] [C02BC8A8] ip_output+0x120/0x244
[DD2D7C90] [C02BD8DC] ip_queue_xmit+0x17c/0x408
[DD2D7D00] [C02CEB1C] tcp_transmit_skb+0x358/0x7bc
[DD2D7D40] [C02C2FC0] tcp_cleanup_rbuf+0xb8/0x158
[DD2D7D50] [C02C5C14] tcp_recvmsg+0x4c0/0xbcc
[DD2D7DB0] [C0294490] sock_common_recvmsg+0x3c/0x60
[DD2D7DD0] [C02920E4] sock_aio_read+0x10c/0x114
[DD2D7E30] [C006F210] do_sync_read+0xc4/0x138
[DD2D7EF0] [C006FECC] vfs_read+0x19c/0x1a4
[DD2D7F10] [C00702E4] sys_read+0x4c/0x90
[DD2D7F40] [C00122EC] ret_from_syscall+0x0/0x38
--- Exception: c01 at 0xff5ba98
    LR = 0x10032fc0
Instruction dump:
5400fffe 0f000000 81030020 81230024 39680001 7c0b53d6 7c0051d6 7d605850
7d694a78 91630020 7d290034 5529d97e <0f090000> 7d034378 4e800020 2f840001
 <0>Kernel panic - not syncing: Fatal exception in interrupt
 <0>Rebooting in 180 seconds..<4>atkbd.c: Spurious ACK on isa0060/serio0. Some .
atkbd.c: Spurious ACK on isa0060/serio0. Some program might be trying access ha.
atkbd.c: Spurious ACK on isa0060/serio0. Some program might be trying access ha.
