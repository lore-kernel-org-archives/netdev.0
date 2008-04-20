From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: atl1 64-bit => 32-bit DMA borkage (reproducible, bisected)
Date: Sat, 19 Apr 2008 21:54:44 -0500
Message-ID: <20080419215444.2d4623f5@osprey.hogchain.net>
References: <20080410203354.f0a6f464.akpm@linux-foundation.org>
	<20080413204422.GA5136@martell.zuzino.mipt.ru>
	<84144f020804140901p1c076fd2q73e3effe7cd96da3@mail.gmail.com>
	<Pine.LNX.4.64.0804141050550.6296@schroedinger.engr.sgi.com>
	<20080414183221.GA5234@martell.zuzino.mipt.ru>
	<20080414195613.GA4772@martell.zuzino.mipt.ru>
	<Pine.LNX.4.64.0804141301580.7803@schroedinger.engr.sgi.com>
	<20080419111719.GA6724@martell.zuzino.mipt.ru>
	<20080419144535.GA4814@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Chris Snook <csnook@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Christoph Lameter <clameter@sgi.com>, torvalds@osdl.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([207.115.11.54]:44312 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751370AbYDTC7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 22:59:49 -0400
In-Reply-To: <20080419144535.GA4814@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 19 Apr 2008 18:45:35 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> OK, nailed it.
> 
> It's commit 5f08e46b621a769e52a9545a23ab1d5fb2aec1d4 aka "atl1:
> disable broken 64-bit DMA".
> 
> With this commit in tree, I can reproduce either
> a) kmalloc-2048 corruption after initscripts shutdown eth0
> 	http://marc.info/?l=linux-kernel&m=120820360221261&w=2
> 
> b) or oopses at filp_close() first reported long ago
> 	(sorry, can't find that email)
> 
> c) or hard hang after initscripts shutdown eth0 with even SysRq not
> working. http://marc.info/?l=linux-kernel&m=120795046008115&w=2
> 
> I have two boxes one with atl1, 4G RAM with 2G remapped after 4G
> boundary, another with r8169 connected with just ethernet cable. NICs
> agree on 1Gbps speed.
> 
> So, it's enough to scp 200 MB git archive and immediately start
> rebooting sequence for horrors described above to appear. It's not
> 100% reproducible but more like 90%.

Do I understand correctly that these failures occur only while the
network interface is going down?

Jay
