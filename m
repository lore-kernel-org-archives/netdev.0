From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] selinux/netlabel.c should #include "netlabel.h"
Date: Wed, 27 Feb 2008 23:55:43 +0200
Message-ID: <20080227215543.GW29269@cs181133002.pp.htv.fi>
References: <20080227212042.GK29269@cs181133002.pp.htv.fi> <200802271642.57556.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: sds@tycho.nsa.gov, jmorris@namei.org, eparis@parisplace.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:34824 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbYB0V4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 16:56:54 -0500
Content-Disposition: inline
In-Reply-To: <200802271642.57556.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, 2008 at 04:42:57PM -0500, Paul Moore wrote:
> On Wednesday 27 February 2008 4:20:42 pm Adrian Bunk wrote:
> > Every file should include the headers containing the externs for its
> > global code.
> >
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> It doesn't _need_ the file in the strictest sense, the header file is 
> just there for the core SELinux code to call into the NetLabel/SELinux 
> glue code (what is in security/selinux/netlabel.c).  However, if this 
> is to conform better to kernel coding policy (I assume that is the case 
> here?) then that is fine with me.

I'm not claiming it needs it.

But with this #include gcc can check that the prototypes in netlabel.h 
match the functions in netlabel.c

The bugs this catches are rare, but when you have such a bug it can be 
nasty to debug.

> Acked-by: Paul Moore <paul.moore@hp.com>
> 
> > ---
> > 1f65757bac3e82514b447822ab30ee10d33a59a2 foobar
> > diff --git a/security/selinux/netlabel.c
> > b/security/selinux/netlabel.c index 0fa2be4..6d22d76 100644
> > --- a/security/selinux/netlabel.c
> > +++ b/security/selinux/netlabel.c
> > @@ -34,6 +34,7 @@
> >
> >  #include "objsec.h"
> >  #include "security.h"
> > +#include "netlabel.h"
> >
> >  /**
> >   * selinux_netlbl_sidlookup_cached - Cache a SID lookup
> 
> paul moore

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

