From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.25-rc3ish TCP assertion & WARN_ON
Date: Sat, 1 Mar 2008 22:19:07 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803012213190.350@kivilampi-30.cs.helsinki.fi>
References: <20080301183234.GA4707@puku.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Chris Wedgwood <cw@f00f.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44966 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757065AbYCAUTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 15:19:10 -0500
In-Reply-To: <20080301183234.GA4707@puku.stupidest.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1 Mar 2008, Chris Wedgwood wrote:

> Running a near-mainline kernel (v2.6.25-rc3-1123-g066241f with some
> local kvm changes).
> 
> 
> I've seen this a few times since upgrading psat 2.6.24rc3 (where I
> never saw it) but declined to report it initially thinking it might be
> the result of a kvm problem.
> 
> With the latest crash that seems a less likely, it was several hours
> since using kvm whilst the machine was under light network load.
> 
>     [114135.072844] KERNEL: assertion (packets <= tp->packets_out) failed at net/ipv4/tcp_input.c (2139)
> [ ... repeated another 22 times in rapid succession ... ]
>     [114135.115359] KERNEL: assertion (packets <= tp->packets_out) failed at net/ipv4/tcp_input.c (2139)
>     [114135.115984] ------------[ cut here ]------------
>     [114135.116001] WARNING: at net/ipv4/tcp_input.c:2506 tcp_ack+0xe72/0x1bae()
>     [114135.116031] Modules linked in: kvm_amd kvm loop tun firewire_ohci firewire_core crc_itu_t [last unloaded: kvm]
>     [114135.116073] Pid: 0, comm: swapper Not tainted 2.6.25-rc3-cw3 #6
>     [114135.116091] 
>     [114135.116092] Call Trace:
>     [114135.116116]  <IRQ>  [<ffffffff80231aeb>] warn_on_slowpath+0x58/0x6b
>     [114135.116142]  [<ffffffff8053c4fb>] ? _spin_unlock_bh+0x2f/0x34
>     [114135.116165]  [<ffffffff804fb479>] ? bictcp_cong_avoid+0x33/0x258
>     [114135.116184]  [<ffffffff804c8dc3>] tcp_ack+0xe72/0x1bae

Please try with the debug patch that is available in here:

  http://marc.info/?l=linux-kernel&m=120418703023153&w=2

It consumes some cpu by validating the whole TCP's write queue multiple 
times per ACK to find most of the errors as soon as they happen rather 
than when some cheap mainline trap triggers (often much later than the 
actual bug).

-- 
 i.
