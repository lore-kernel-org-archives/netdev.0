From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG][AX25] Fwd: SMP with AX.25
Date: Thu, 7 Feb 2008 20:35:11 +0100
Message-ID: <20080207193511.GB8149@ami.dom.local>
References: <20080206074529.GC4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Jann Traschewski <jann@gmx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:64620 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755793AbYBGTbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 14:31:34 -0500
Received: by nf-out-0910.google.com with SMTP id g13so981331nfb.21
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2008 11:31:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080206074529.GC4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here I resend another OOPS I got from Jann:

On Thu, Feb 07, 2008 at 05:42:42PM +0100, Jann Traschewski wrote:
...
> BUG: unable to handle kernel NULL pointer dereference at virtual address
> 00000065
> printing eip: c02266c7 *pde = 00000000
> Oops: 0000 [#1] SMP
> Modules linked in: netconsole ppp_deflate zlib_deflate zlib_inflate bsd_comp
> ppp_async ppp_generic slhc tun bitrev crc32 mkiss ax25 crc16 iptable_nat
> nf_nat nf_conntrack_ipv4 xt_state nf_conntrack ipt_REJECT iptable_filter
> iptable_mangle xt_MARK ipv6 ipip tunnel4 ide_cd cdrom aic7xxx
> scsi_transport_spi parport_serial parport_pc parport i2c_piix4 genrtc
> 
> Pid: 3035, comm: linuxnet Not tainted (2.6.24-dg8ngn #1)
> EIP: 0060:[<c02266c7>] EFLAGS: 00010202 CPU: 0
> EIP is at skb_clone+0x3/0x4d
> EAX: 00000000 EBX: 00000000 ECX: 00000001 EDX: 00000020
> ESI: 00000008 EDI: 00000000 EBP: f700a4ac ESP: f720b9ac
>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Process linuxnet (pid: 3035, ti=f720a000 task=f7c63570 task.ti=f720a000)
> Stack: f700a400 f8a0a8f9 c01254db 00000000 00000000 f700a400 f700a4cc
> f700a400 __wake_up_common+0x32/0x5c
> __wake_up+0x32/0x42
>  [<c0224e67>] sock_def_readable+0x39/0x63
>  [<c02251e1>] sock_queue_rcv_skb+0xb6/0xd1
>  [<c022b060>] netif_receive_skb+0x309/0x372
>  [<c0117f35>] dequeue_entity+0xb/0x2a
>  [<c022d42f>] process_backlog+0x5c/0xaa
>  [<c022cf21>] net_rx_action+0x8d/0x173
>  [<c012213a>] __do_softirq+0x5d/0xc1
>  [<c01221d0>] do_softirq+0x32/0x36
>  [<c01223df>] local_bh_enable_ip+0x35/0x40
>  [<c0261ebe>] udp_poll+0xc1/0xd5
>  [<c0220f2c>] sock_poll+0xc/0xe
>  [<c016495a>] do_select+0x229/0x3c9
>  [<c01650b6>] __pollwait+0x0/0xac
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c0118e73>] default_wake_function+0x0/0x8
>  [<c011756c>] __wake_up_common+0x32/0x5c
>  [<c011911c>] __wake_up+0x32/0x42
>  [<c0164da0>] core_sys_select+0x2a6/0x2c7
>  [<c011756c>] __wake_up_common+0x32/0x5c
>  [<c011911c>] __wake_up+0x32/0x42
>  [<c01d13c2>] tty_wakeup+0x4c/0x50
>  [<c01d72c6>] pty_unthrottle+0x12/0x1d
>  [<f89fc60e>] mkiss_receive_buf+0x381/0x3af [mkiss]
> sys_select+0xa4/0x187
> syscall_call+0x7/0xb
> Kernel panic - not syncing: Fatal exception in interrupt
