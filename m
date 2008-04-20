From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Sun, 20 Apr 2008 16:26:31 +0400
Message-ID: <20080420122631.GA4761@martell.zuzino.mipt.ru>
References: <84144f020804140901p1c076fd2q73e3effe7cd96da3@mail.gmail.com> <Pine.LNX.4.64.0804141050550.6296@schroedinger.engr.sgi.com> <20080414183221.GA5234@martell.zuzino.mipt.ru> <20080414195613.GA4772@martell.zuzino.mipt.ru> <Pine.LNX.4.64.0804141301580.7803@schroedinger.engr.sgi.com> <20080419111719.GA6724@martell.zuzino.mipt.ru> <20080419144535.GA4814@martell.zuzino.mipt.ru> <20080419215444.2d4623f5@osprey.hogchain.net> <20080420111453.GA4902@martell.zuzino.mipt.ru> <20080420060607.2b1be48b@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:54788 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbYDTLbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 07:31:12 -0400
Received: by fk-out-0910.google.com with SMTP id 19so1698117fkr.5
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 04:31:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080420060607.2b1be48b@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 20, 2008 at 06:06:07AM -0500, Jay Cliburn wrote:
> On Sun, 20 Apr 2008 15:14:53 +0400
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > On Sat, Apr 19, 2008 at 09:54:44PM -0500, Jay Cliburn wrote:
> > > On Sat, 19 Apr 2008 18:45:35 +0400
> > > Alexey Dobriyan <adobriyan@gmail.com> wrote:
> > > 
> > > > OK, nailed it.
> > > > 
> > > > It's commit 5f08e46b621a769e52a9545a23ab1d5fb2aec1d4 aka "atl1:
> > > > disable broken 64-bit DMA".
> > > > 
> > > > With this commit in tree, I can reproduce either
> > > > a) kmalloc-2048 corruption after initscripts shutdown eth0
> > > > 	http://marc.info/?l=linux-kernel&m=120820360221261&w=2
> > > > 
> > > > b) or oopses at filp_close() first reported long ago
> > > > 	(sorry, can't find that email)
> > > > 
> > > > c) or hard hang after initscripts shutdown eth0 with even SysRq
> > > > not working.
> > > > http://marc.info/?l=linux-kernel&m=120795046008115&w=2
> > > > 
> > > > I have two boxes one with atl1, 4G RAM with 2G remapped after 4G
> > > > boundary, another with r8169 connected with just ethernet cable.
> > > > NICs agree on 1Gbps speed.
> > > > 
> > > > So, it's enough to scp 200 MB git archive and immediately start
> > > > rebooting sequence for horrors described above to appear. It's not
> > > > 100% reproducible but more like 90%.
> > > 
> > > Do I understand correctly that these failures occur only while the
> > > network interface is going down?
> > 
> > Yep. During up or running there were no problems with this card.
> > 
> 
> One more question:  Does it happen whether or not you're using atl1 as
> a netconsole?

Without netconsole bugs happens too.

