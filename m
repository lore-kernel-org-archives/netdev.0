From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.3.0, 3.4-rc1 reproducible tun Oops
Date: Thu, 05 Apr 2012 04:41:04 +0200
Message-ID: <1333593664.18626.577.camel@edumazet-glaptop>
References: <20120404220525.GD21505@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:47623 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab2DEClN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 22:41:13 -0400
Received: by wibhr17 with SMTP id hr17so988981wib.1
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 19:41:11 -0700 (PDT)
In-Reply-To: <20120404220525.GD21505@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-04 at 15:05 -0700, Simon Kirby wrote:
> I use an SSH VPN occasionally from home, and since upgrading the
> remote
> kernel to 3.3.0, the it now seems to Oops when I ^C the tunnel with
> sockets still active. If I start the tunnel, log in to a box through
> it
> and run "vmstat 1", ^C the tunnel SSH process, and start it up again,
> I
> get an Oops like this:
> 
> BUG: unable to handle kernel NULL pointer dereference at
> 00000000000000ff
> IP: [<ffffffff810ed5fa>] __kmalloc_track_caller+0xaa/0x1b0
> PGD 12d2bc067 PUD 0
> Oops: 0000 [#1] SMP
> CPU 1
> Modules linked in: nf_conntrack_netlink nfnetlink iptable_mangle
> ipt_MASQUERADE xt_state xt_conntrack iptable_nat nf_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack hwmon_vid ppp_async
> ppp_generic slhc crc_ccitt tun nvidia(PO) uvcvideo videobuf2_vmalloc
> videobuf2_memops videobuf2_core e100
> 
> Pid: 16156, comm: sshd Tainted: P           O 3.3.0 #32 System
> manufacturer System Product Name/A8N-VM CSM

Hmm, is it happening if you remove the nvidia module ?

If yes, please try to add slub_debug=FZPU

CONFIG_SLUB_DEBUG=y
CONFIG_SLUB=y
# CONFIG_SLUB_DEBUG_ON is not set
