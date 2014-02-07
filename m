From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 19/26] drivers: isdn: Move prototype declaration to
 header file platform.h from diva_didd.c
Date: Fri, 7 Feb 2014 09:15:16 -0800
Message-ID: <20140207171516.GA7298@jtriplet-mobl1>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
 <93d7188538418423685ecefaf3d2bb311b37be6e.1390408518.git.rashika.kheria@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6BA76D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Rashika Kheria' <rashika.kheria@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6BA76D@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 07, 2014 at 01:33:46PM +0000, David Laight wrote:
> From: Rashika Kheria
> > Move prototype declarations of function to header file
> > hardware/eicon/platform.h because they are used by more than one file.
> > 
> > This eliminates the following warnings in hardware/eicon/diddfunc.c:
> > drivers/isdn/hardware/eicon/diddfunc.c:95:12: warning: no previous prototype for diddfunc_init [-
> > Wmissing-prototypes]
> > drivers/isdn/hardware/eicon/diddfunc.c:110:13: warning: no previous prototype for diddfunc_finit [-
> > Wmissing-prototypes]
> ...
> > diff --git a/drivers/isdn/hardware/eicon/diva_didd.c b/drivers/isdn/hardware/eicon/diva_didd.c
> > index fab6ccf..56d32a7 100644
> > --- a/drivers/isdn/hardware/eicon/diva_didd.c
> > +++ b/drivers/isdn/hardware/eicon/diva_didd.c
> > @@ -39,9 +39,6 @@ MODULE_LICENSE("GPL");
> >  #define DBG_MINIMUM  (DL_LOG + DL_FTL + DL_ERR)
> >  #define DBG_DEFAULT  (DBG_MINIMUM + DL_XLOG + DL_REG)
> > 
> > -extern int diddfunc_init(void);
> > -extern void diddfunc_finit(void);
> > -
> >  extern void DIVA_DIDD_Read(void *, int);
> 
> You should move that one as well.
> There really shouldn't be 'extern' definitions for any function in
> any C files since you want the compiler to check they are correct
> when the function itself is compiled.

Absolutely, but as far as I can tell Rashika is doing this
incrementally, organized more by header than by source file, so I'd
expect a few externs in a source file to disappear at a time rather than
all in one patch.

- Josh Triplett
