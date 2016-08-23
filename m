From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: [PATCH v05 21/72] include/uapi/linux/if_pppox.h: include
 linux/if.h
Date: Tue, 23 Aug 2016 09:41:52 +0300
Message-ID: <20160823064152.GJ5399@lakka.kapsi.fi>
References: <1471890809-4383-1-git-send-email-mikko.rapeli@iki.fi>
 <1471890809-4383-22-git-send-email-mikko.rapeli@iki.fi>
 <20160822123745.7921a88d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160822123745.7921a88d@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 22, 2016 at 12:37:45PM -0700, Stephen Hemminger wrote:
> On Mon, 22 Aug 2016 20:32:38 +0200
> Mikko Rapeli <mikko.rapeli@iki.fi> wrote:
> 
> > Fixes userspace compilation error:
> > 
> > error: ‘IFNAMSIZ’ undeclared here (not in a function)
> > 
> > Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> > ---
> >  include/uapi/linux/if_pppox.h | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/include/uapi/linux/if_pppox.h b/include/uapi/linux/if_pppox.h
> > index e128769..473c3c4 100644
> > --- a/include/uapi/linux/if_pppox.h
> > +++ b/include/uapi/linux/if_pppox.h
> > @@ -21,6 +21,7 @@
> >  #include <asm/byteorder.h>
> >  
> >  #include <linux/socket.h>
> > +#include <linux/if.h>
> >  #include <linux/if_ether.h>
> >  #include <linux/if_pppol2tp.h>
> >  
> 
> I went back to the first patch in LKML for this series.
> It seems your goal is that every include file should be standalone,
> i.e it must include every definition it uses.
> 
> I disagree with this premise. It just makes things harder to maintain with
> no real gain for any existing program.  What is the motivation for all this
> useless churn? Is there some silly style rule that should be fixed instead?

With over 700 uapi headers exported to userspace by Linux kernel, how
do I find out the 'correct' order of including them if they can not be
included alone? Any hints on automating that?

My first trial was to include all of the uapi headers as a single bunch to
abi checker tool which calls gcc on them, but the compilation result was
so bad and hopeless that I decided to try feeding each header file one by
one to the compiler and here I am over two years later still fixing these
issues.

I came up with the rule because to me it makes sense. Several kernel
devs agree with this approach and have accepted patches.

If your kernel subsystem uapi headers have a single entry point header file,
then all of the others can just depend on that and be done with it.
For example most (if not all) drm driver specific headers include <drm/drm.h>.

-Mikko
