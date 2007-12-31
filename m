From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 19:51:58 +0200
Message-ID: <20071231175158.GA2360@does.not.exist>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz> <20071231122419.GA13803@does.not.exist> <alpine.LSU.0.999.0712311335210.3761@be1.lrz> <20071231144255.GB13803@does.not.exist> <alpine.LSU.0.999.0712311553530.4211@be1.lrz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jan Engelhardt <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Bodo Eggert <7eggert@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:51172 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473AbXLaRwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 12:52:10 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LSU.0.999.0712311553530.4211@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2007 at 04:19:23PM +0100, Bodo Eggert wrote:
> On Mon, 31 Dec 2007, Adrian Bunk wrote:
> > On Mon, Dec 31, 2007 at 02:26:42PM +0100, Bodo Eggert wrote:
> > > On Mon, 31 Dec 2007, Adrian Bunk wrote:
> > > > On Mon, Dec 31, 2007 at 01:09:43PM +0100, Bodo Eggert wrote:
> 
> > > > > As suggested by Adrian Bunk, UNIX domain sockets should always be built in 
> > > > > on normal systems. This is especially true since udev needs these sockets
> > > > > and fails to run if UNIX=m.
> > > > > 
> > > > > Signed-Off-By: Bodo Eggert <7eggert@gmx.de>
> > > > > 
> > > > > ---
> > > > > Last minute change: I decided against making it a bool because embedded 
> > > > > folks might depend on a small kernel image. Edited in the patch below.
> > > > >...
> > > > 
> > > > Is this just a purely theoretical thought or is this a reasonable use 
> > > > case people actually use in practice?
> > >  
> > > For now, it's a theoretical thought, but having an embedded device, I can 
> > > see the reason for $EVERYTHING=m there.
> > 
> > The only advantage I see is that the kernel image you have to flash 
> > can be made smaller - with the disadvantage that the running kernel
> > is bigger by more than 10%.
> > 
> > If you don't believe me, try it yourself:
> > Build all drivers statically into your kernel, and then compare the 
> > vmlinux sizes with CONFIG_MODULES=n and CONFIG_MODULES=y.
> 
> If you'd aim for a small kernel image, you would build anything as a module 
> that is not requred for booting.
> 
> > > > After all, changing it to a bool will allow us to make the kernel image 
> > > > for nearly everyone smaller by a few hundred bytes...
> > > 
> > > I can't see why optionally building it as a module would force us to make 
> > > the kernel bigger. It may be a little more ugly to support =m, but thats it,
> > > isn't it?
> > 
> > On architectures like x86 where __exit code is freed at runtime 
> > af_unix_exit() makes your kernel image (but not the running kernel) 
> > bigger.
> > 
> > With CONFIG_MODULES=y the 13 EXPORT_SYMBOL's that only exist for the 
> > theoretical possibility of CONIG_UNIX=m waste a few hundred bytes 
> > of memory.
> 
> #define m='m'
> #if CONIG_UNIX=='m'
> #define EXPORT_SYMBOL_AF_UNIX EXPORT_SYMBOL
> #else
> #define EXPORT_SYMBOL_AF_UNIX()
> #endif
> #undef m
> 
> You could also use "#if defined(C_U) && (C_U == m)".

Look at the number of exports in the kernel and the number of lines 
changed per months, and it becomes obvious that somwthing like that
would not be maintainable.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

