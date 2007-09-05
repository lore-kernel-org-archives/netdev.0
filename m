From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: kernel crashes inside MV643xx driver
Date: Wed, 5 Sep 2007 17:03:56 +0100
Message-ID: <20070905170356.0e644978@oldman>
References: <46C93701.7050509@alcatel-lucent.com>
	<20070905082452.4a20387b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gshan <gshan@alcatel-lucent.com>, linux-kernel@vger.kernel.org,
	Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48233 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756701AbXIEQD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 12:03:59 -0400
In-Reply-To: <20070905082452.4a20387b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 5 Sep 2007 08:24:52 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > On Mon, 20 Aug 2007 14:38:57 +0800 gshan <gshan@alcatel-lucent.com> wrote:
> > Hi All,
> > 
> > After I started the NFS server, it crashed:
> > 
> > <3>Badness in local_bh_enable at 
> > /home/cli4/sandbox/main/TelicaRoot/components/mvlinux/cge/devkit/lsp/7xx/linux/kernel/softirq.c:195
> > Badness in local_bh_enable at 
> > /home/cli4/sandbox/main/TelicaRoot/components/mvlinux/cge/devkit/lsp/7xx/linux/kernel/softirq.c:195
> > Call trace:
> >  [c0005340] check_bug_trap+0xbc/0x11c
> >  [c0005604] ProgramCheckException+0x264/0x2bc
> >  [c0004ac4] ret_from_except_full+0x0/0x4c
> >  [c0022ae4] local_bh_enable+0x18/0x80
> >  [c024648c] skb_copy_bits+0x168/0x3b8
> >  [c024db44] __skb_linearize+0x90/0x150
> >  [c020e8a4] mv643xx_eth_start_xmit+0x4c0/0x5bc
> >  [c025c934] qdisc_restart+0xac/0x2bc
> >  [c024de9c] dev_queue_xmit+0x298/0x34c
> >  [c0269814] ip_finish_output+0x140/0x2b8
> >  [c026a3ac] ip_fragment+0x3cc/0x6e0
> >  [c026bac8] ip_push_pending_frames+0x3dc/0x46c
> >  [c0289ec4] udp_push_pending_frames+0x10c/0x1cc
> >  [c028a7c4] udp_sendpage+0x104/0x188
> >  [c0292fc8] inet_sendpage+0x90/0xb8
> > 
> > I searched the webs and found the similar problems:
> > http://www.mail-archive.com/netdev@vger.kernel.org/msg05199.html
> > http://oss.sgi.com/archives/netdev/2005-09/msg00025.html
> > 
> > Who knew there are fixes for the problem?
> > 
> 
> Well that got a tremendous response, didn't it?
> 
> What do you mean by "crashed"?  The above is a warning and the system
> should have survived.
> 
> Which kernel version is being used?

The transmit start rework look like it should have already fixed the problem.
The driver was calling spin_lock_irqsave before calling skb_linearize, now
it checks first.

commit c8aaea25e0b069e9572caa74f984e109899c1765
Author: Dale Farnsworth <dale@farnsworth.org>
Date:   Fri Mar 3 10:02:05 2006 -0700

    [PATCH] mv643xx_eth: Refactor tx command queuing code
    
    Simplify and remove redundant code for filling transmit descriptors.
    No changes in features; it's just a code reorganization/cleanup.
    
    Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>
