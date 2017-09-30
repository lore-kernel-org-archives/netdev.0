From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH v2] lib: fix multiple strlcpy definition
Date: Sat, 30 Sep 2017 23:29:41 +0300
Message-ID: <20170930202941.7fzp436mcuccy2d4@tarshish>
References: <6910008ec8db3f63c8120b1624a08328cd203e92.1506621731.git.baruch@tkos.co.il>
 <20170929115858.275217b8@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:50415 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751251AbdI3U3q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 30 Sep 2017 16:29:46 -0400
Content-Disposition: inline
In-Reply-To: <20170929115858.275217b8@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Fri, Sep 29, 2017 at 11:58:58AM -0700, Stephen Hemminger wrote:
> On Thu, 28 Sep 2017 21:02:11 +0300
> Baruch Siach <baruch@tkos.co.il> wrote:
> 
> > Some C libraries, like uClibc and musl, provide BSD compatible
> > strlcpy(). Add check_strlcpy() to configure, and avoid defining strlcpy
> > and strlcat when the C library provides them.
> > 
> > This fixes the following static link error with uClibc-ng:
> > 
> > .../sysroot/usr/lib/libc.a(strlcpy.os): In function `strlcpy':
> > strlcpy.c:(.text+0x0): multiple definition of `strlcpy'
> > ../lib/libutil.a(utils.o):utils.c:(.text+0x1ddc): first defined here
> > collect2: error: ld returned 1 exit status
> > 
> > Acked-by: Phil Sutter <phil@nwl.cc>
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> 
> This is OK because it doesn't impact normal glibc too much.
> 
> > diff --git a/lib/Makefile b/lib/Makefile
> > index 0fbdf4c31f50..132ad00c3335 100644
> > --- a/lib/Makefile
> > +++ b/lib/Makefile
> > @@ -1,5 +1,9 @@
> >  include ../config.mk
> >  
> > +ifeq ($(NEED_STRLCPY),y)
> > +	CFLAGS += -DNEED_STRLCPY
> > +endif
> > +
> 
> I just removed all the conditional CFLAGS out of subdirectory Makefiles
> and moved them into the generated config.mk. Please do that for this
> as well and resubmit.

What code do you refer to? I don't see that as of current master 
(e4139268ba96).

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -
