From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] Make FC, FDDI, HIPPI and TR tristate
Date: Sat, 29 Dec 2007 02:52:08 +0200
Message-ID: <20071229005208.GE9105@does.not.exist>
References: <Pine.LNX.4.64.0712282348280.29013@fbirervta.pbzchgretzou.qr> <20071229000930.GD9105@does.not.exist> <Pine.LNX.4.64.0712290140090.29013@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:53158 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbXL2AwU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2007 19:52:20 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712290140090.29013@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 29, 2007 at 01:41:23AM +0100, Jan Engelhardt wrote:
> 
> On Dec 29 2007 02:09, Adrian Bunk wrote:
> >On Sat, Dec 29, 2007 at 12:45:12AM +0100, Jan Engelhardt wrote:
> >> Turn CONFIG_FC, CONFIG_FDDI, CONFIG_HIPPI and CONFIG_TR into tristate
> >> so they can be built as modules. This will allow CONFIG_LLC to be
> >> built as a module too, overall reducing the core kernel image size.
> >>...
> >
> >Just an example of code you have to fix if you do this:
> >
> >$ grep -r "#ifdef CONFIG_TR" net/
> 
> Ah, thank you for reminding me. For lec.c, would it be ok to do
> 
> #if defined(CONFIG_TR) || defined(CONFIG_TR_MODULE)
> #	define WITH_TR 1
> #endif
>...

#if defined(CONFIG_TR) || (defined(CONFIG_TR_MODULE) && defined(MODULE))

Otherwise stuff like calling alloc_trdev() will cause build errors with 
CONFIG_TR=m, CONFIG_ATM_LANE=y.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

