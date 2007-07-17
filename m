From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [irda-users] [PATCH] [IrDA] Fix IrDA build failure
Date: Tue, 17 Jul 2007 07:08:12 +0200
Message-ID: <20070717050812.GA3801@stusta.de>
References: <20070716111715.GB22757@mail.solidboot.com> <20070716130052.GC22757@mail.solidboot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, sam@ravnborg.org, stable@kernel.org,
	eric.y.miao@gmail.com, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Samuel Ortiz <samuel.ortiz@solidboot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:35189 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753318AbXGQFIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 01:08:51 -0400
Content-Disposition: inline
In-Reply-To: <20070716130052.GC22757@mail.solidboot.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16, 2007 at 04:00:52PM +0300, Samuel Ortiz wrote:
> On Mon, Jul 16, 2007 at 02:17:15PM +0300, Samuel Ortiz wrote:
> > Hi Dave,
> > 
> > When having built-in IrDA, we hit the following error:
> > 
> > `irda_sysctl_unregister' referenced in section `.init.text' of
> > net/built-in.o: defined in discarded section `.exit.text' of
> > net/built-in.o
> > `irda_proc_unregister' referenced in section `.init.text' of
> > net/built-in.o: defined in discarded section `.exit.text' of
> > net/built-in.o
> > `irsock_cleanup' referenced in section `.init.text' of net/built-in.o:
> > defined in discarded section `.exit.text' of net/built-in.o
> > `irttp_cleanup' referenced in section `.init.text' of net/built-in.o:
> > defined in discarded section `.exit.text' of net/built-in.o
> > `iriap_cleanup' referenced in section `.init.text' of net/built-in.o:
> > defined in discarded section `.exit.text' of net/built-in.o
> > `irda_device_cleanup' referenced in section `.init.text' of
> > net/built-in.o: defined in discarded section `.exit.text' of
> > net/built-in.o
> > `irlap_cleanup' referenced in section `.init.text' of net/built-in.o:
> > defined in discarded section `.exit.text' of net/built-in.o
> > `irlmp_cleanup' referenced in section `.init.text' of net/built-in.o:
> > defined in discarded section `.exit.text' of net/built-in.o
> > make[1]: *** [.tmp_vmlinux1] Error 1
> > make: *** [_all] Error 2
> > 
> > This is due to the irda_init fix recently added, where we call __exit
> > routines from an __init one. It is a build failure that I didn't catch
> > because it doesn't show up when building IrDA as a module. My apologies
> > for that.
> I forgot to mention that the build fails on ARM but not on x86. As Sam
> explained to me, x86 discards exit sections at runtime only, unlike ARM.
> I don't know about other platforms though.
> 
> So, to hit this build failure, you need a combination of !x86 and
> built-in IrDA.

On i386 these are runtime failures (although in unlikely error paths) 
which isn't better.

> Cheers,
> Samuel.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

