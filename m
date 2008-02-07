From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG][AX25] Fwd: SMP with AX.25
Date: Thu, 7 Feb 2008 21:34:29 +0100
Message-ID: <20080207203428.GC8149@ami.dom.local>
References: <20080206074529.GC4496@ff.dom.local> <20080207193511.GB8149@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Jann Traschewski <jann@gmx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:22952 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbYBGUaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 15:30:23 -0500
Received: by ug-out-1314.google.com with SMTP id z38so763715ugc.16
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2008 12:30:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080207193511.GB8149@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2008 at 08:35:11PM +0100, Jarek Poplawski wrote:
> Here I resend another OOPS I got from Jann:
> 
> On Thu, Feb 07, 2008 at 05:42:42PM +0100, Jann Traschewski wrote:
> ...
> > BUG: unable to handle kernel NULL pointer dereference at virtual address
> > 00000065
> > printing eip: c02266c7 *pde = 00000000
> > Oops: 0000 [#1] SMP
> > Modules linked in: netconsole ppp_deflate zlib_deflate zlib_inflate bsd_comp
> > ppp_async ppp_generic slhc tun bitrev crc32 mkiss ax25 crc16 iptable_nat
> > nf_nat nf_conntrack_ipv4 xt_state nf_conntrack ipt_REJECT iptable_filter
> > iptable_mangle xt_MARK ipv6 ipip tunnel4 ide_cd cdrom aic7xxx
> > scsi_transport_spi parport_serial parport_pc parport i2c_piix4 genrtc
> > 
> > Pid: 3035, comm: linuxnet Not tainted (2.6.24-dg8ngn #1)
> > EIP: 0060:[<c02266c7>] EFLAGS: 00010202 CPU: 0
> > EIP is at skb_clone+0x3/0x4d
> > EAX: 00000000 EBX: 00000000 ECX: 00000001 EDX: 00000020
> > ESI: 00000008 EDI: 00000000 EBP: f700a4ac ESP: f720b9ac
> >  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> > Process linuxnet (pid: 3035, ti=f720a000 task=f7c63570 task.ti=f720a000)
> > Stack: f700a400 f8a0a8f9 c01254db 00000000 00000000 f700a400 f700a4cc
> > f700a400 __wake_up_common+0x32/0x5c
> > __wake_up+0x32/0x42

Jann, this report is a bit damaged here, so I could be wrong, but it
looks similar to your first reports, and I guess this skb_clone is
called from ax25_kick too. Then my today testing patch #2 should help
for this, I hope.

Jarek P.
