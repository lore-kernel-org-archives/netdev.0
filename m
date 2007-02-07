From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] Broken ArcNet com20020 pcmcia driver in 2.6.20
Date: Wed, 7 Feb 2007 14:58:05 -0800
Message-ID: <20070207145805.863a6039.randy.dunlap@oracle.com>
References: <Pine.LNX.4.64.0702071418440.31566@frodo.shire>
	<45CA0373.5080508@oracle.com>
	<Pine.LNX.4.64.0702072315080.31566@frodo.shire>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Esben Nielsen <nielsen.esben@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:47313 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161475AbXBGXDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 18:03:39 -0500
In-Reply-To: <Pine.LNX.4.64.0702072315080.31566@frodo.shire>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Feb 2007 23:24:21 +0100 (CET) Esben Nielsen wrote:

> On Wed, 7 Feb 2007, Randy Dunlap wrote:
> 
> > Esben Nielsen wrote:
> >>  Hi,
> >>  I can not get my com20020 pcmcia driver to work as a module under 2.6.20.
> >>  There is the build problem:
> >
> The relevant parts:
> ...
> CONFIG_ARCNET_COM20020=m
> # CONFIG_ARCNET_COM20020_ISA is not set
> # CONFIG_ARCNET_COM20020_PCI is not set
> ...
> CONFIG_ARCNET_COM20020_CS=m

Sorry about that.

> In this hiracy it is not nice for the com20020 module to check wether 
> there are users for it. It breaks the direction of dependency. What if I 
> first compile com20020 install it, and then decide I want one of the other
> modules? Then would I have to recompile com20020 and reload it.
> Therefore: Remove the check, do always export the symbols.

That's not the usual kernel way, but I'll leave it up to the netdev
people.  (and net mailing list changed from linux-net to netdev)

An alternative patch is below.
Thanks for your report and patch.


> As for actually testing: I have access to ArcNet hardware for 3 more 
> weeks. Then I will start at a new job, where there is no ArcNet.

> >> WARNING:  "com20020_found" [drivers/net/pcmcia/com20020_cs.ko] undefined!
> >> WARNING:  "com20020_check" [drivers/net/pcmcia/com20020_cs.ko] undefined!
> >>
> >>  The solution:
> >>  Always export com20020_found and com20020_check.
> >>
> >>  Esben
> >>
> >>   drivers/net/arcnet/com20020.c |    3 ---
> >>   1 file changed, 3 deletions(-)
> >>
> >>  Index: linux-2.6.20/drivers/net/arcnet/com20020.c
> >>  ===================================================================
> >>  --- linux-2.6.20.orig/drivers/net/arcnet/com20020.c
> >>  +++ linux-2.6.20/drivers/net/arcnet/com20020.c
> >>  @@ -337,11 +337,8 @@ static void com20020_set_mc_list(struct
> >>       }
> >>   }
> >>
> >>  -#if defined(CONFIG_ARCNET_COM20020_PCI_MODULE) || \
> >>  -    defined(CONFIG_ARCNET_COM20020_ISA_MODULE)
> >>   EXPORT_SYMBOL(com20020_check);
> >>   EXPORT_SYMBOL(com20020_found);
> >>  -#endif
> >>
> >>   MODULE_LICENSE("GPL");
---


From: Randy Dunlap <randy.dunlap@oracle.com>

Need to export com20020 symbols for com20020_cs also.

WARNING:  "com20020_found" [drivers/net/pcmcia/com20020_cs.ko] undefined!
WARNING:  "com20020_check" [drivers/net/pcmcia/com20020_cs.ko] undefined!

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/arcnet/com20020.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- linux-2620-work.orig/drivers/net/arcnet/com20020.c
+++ linux-2620-work/drivers/net/arcnet/com20020.c
@@ -338,7 +338,8 @@ static void com20020_set_mc_list(struct 
 }
 
 #if defined(CONFIG_ARCNET_COM20020_PCI_MODULE) || \
-    defined(CONFIG_ARCNET_COM20020_ISA_MODULE)
+    defined(CONFIG_ARCNET_COM20020_ISA_MODULE) || \
+    defined(CONFIG_ARCNET_COM20020_CS_MODULE)
 EXPORT_SYMBOL(com20020_check);
 EXPORT_SYMBOL(com20020_found);
 #endif

