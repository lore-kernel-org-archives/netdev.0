From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] qed: Add and use specific logging functions to reduce
 object size
Date: Sun, 31 Jul 2016 11:04:20 -0700
Message-ID: <1469988260.3998.128.camel@perches.com>
References: <a0e0111217e9df2ae8dfd681b2810230e00f634e.1469568146.git.joe@perches.com>
	 <CO2PR11MB00889101E00EA4328672A374970F0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Dept-Eng Everest Linux L2 <Dept-EngEverestLinuxL2@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR11MB00889101E00EA4328672A374970F0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-07-27 at 07:24 +0000, Yuval Mintz wrote:
> > 
> > Current DP_ macros generate a lot of code.
> > Using functions with vsprintf extension %pV helps reduce that size.
> > 
> >  drivers/net/ethernet/qlogic/qed/Makefile   |  2 +-
> >  drivers/net/ethernet/qlogic/qed/qed_util.c | 82 ++++++++++++++++++++++++++++++
> >  include/linux/qed/qed_if.h                 | 60 +++++++++-------------
> >  3 files changed, 106 insertions(+), 38 deletions(-)  create mode 100644
> > drivers/net/ethernet/qlogic/qed/qed_util.c
> This won't compile when CONFIG_QED*=m, as qede can't link to
> the new qed_{err, verbose, info, notice} functions.
> That was the original reason for putting the macros in the interface
> header.
> 
> Other alternatives:
> - We can EXPORT_SYMBOL() the functions, although we've taken a
> strain not adding such to the interface.
>  - Code duplication between qed/qede [ugly].
>  - Implementing this in qede via the interface functions with qed; 
> But the notion of defining an interface between 2 modules passing
> va_args seems [to me] like a bad one.
> 
> If you have cleaner solutions, I'd be happy to hear those.

Hello Yuval.

EXPORT_SYMBOL is probably the simplest solution.

It's pretty commonly used for private logging functions
in drivers/net/, e.g.: drivers/net/wireless/ath/main.c

I'll submit that in awhile.

cheers, Joe
