From: Hannes Eder <hannes@hanneseder.net>
Subject: Re: [PATCH 03/27] drivers/net: fix sparse warning: returning void-valued expression
Date: Sat, 27 Dec 2008 20:11:11 +0100
Message-ID: <49567dd3.0b38560a.3c6c.0511@mx.google.com>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	    <20081222191517.11807.20718.stgit@vmbox.hanneseder.net>
	    <20081225.161740.10052019.davem@davemloft.net>
	    <20081226115921.bb094c58.rdunlap@xenotime.net>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754716AbYL0TLf@vger.kernel.org>
In-Reply-To: <20081226115921.bb094c58.rdunlap@xenotime.net> 
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/26/08, Randy Dunlap <rdunlap@xenotime.net> wrote:
> On Thu, 25 Dec 2008 16:17:40 -0800 (PST)
>  
> David Miller <davem@davemloft.net> wrote:
>  
>  
> > From: Hannes Eder <hannes@hanneseder.net>
>  > Date: Mon, 22 Dec 2008 20:15:17 +0100
>  >
>  > > Fix this sparse warning:
>  > >
>  > >   drivers/net/niu.c:8850:2: warning: returning void-valued expression
>  > >
>  > > Signed-off-by: Hannes Eder <hannes@hanneseder.net>
>  >
>  > Can we just fix sparse not to generate this warning?  It's
>  > marginal, at best.  C++ even explicitly defines this as valid
>  > and last time I brought this up Linus even agreed.
>  
>  
> Ack, I discussed it with him also and he thought that
>  they were just fine as they were...
>  
> 
>  > The types match, the function returns void and it is returning a void,
>  > what is the problem?

In fact there is no need to _fix_ sparse, as there is a command line option
-Wreturn-void / -Wno-return-void, so we could change the Makefile, see diff
below.

---

diff --git a/Makefile b/Makefile
index 64f14aa..cc62984 100644
--- a/Makefile
+++ b/Makefile
@@ -321,7 +321,7 @@ KALLSYMS    = scripts/kallsyms
 PERL           = perl
 CHECK          = sparse
 
-CHECKFLAGS     := -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__ -Wbitwise $(CF)
+CHECKFLAGS     := -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__ -Wbitwise -Wno-return-void $(CF)
 MODFLAGS       = -DMODULE
 CFLAGS_MODULE   = $(MODFLAGS)
 AFLAGS_MODULE   = $(MODFLAGS)
