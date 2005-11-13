From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] rename hostap.c to hostap_main.c
Date: Sun, 13 Nov 2005 17:27:45 +0100
Message-ID: <20051113162745.GM21448@stusta.de>
References: <20051106005343.GF3668@stusta.de> <20051106041543.GC8972@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sam@ravnborg.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964917AbVKMQ1r@vger.kernel.org>
To: hostap@shmoo.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20051106041543.GC8972@jm.kir.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 05, 2005 at 08:15:43PM -0800, Jouni Malinen wrote:
> On Sun, Nov 06, 2005 at 01:53:43AM +0100, Adrian Bunk wrote:
> > I wanted to remove the #include "hostap_ioctl.c" from hostap.c and build 
> > hostap_ioctl.c separately, but this doesn't work since hostap.c has the 
> > same name as the module.
> 
> Is this patch changing anything in hostap.c or is it just a rename of
> the file? Patch file is not exactly ideal for this kind of changes and I
> hope git has a better way of storing this kind of rename.

There's no other change.

If you agree, Jeff might be able to do the

  mv drivers/net/wireless/hostap/hostap.c \
    drivers/net/wireless/hostap/hostap_main.c

plus applying the patch below.

> I would rather not rename the file, but if this is the only way of
> getting the module built in pieces, I'm okay with the change (assuming
> nothing else changed in hostap.c in this changeset).
>...

AFAIK you can't build a module hostap.o consisting of multiple objects 
with the source files of one of them named hostap.c (Sam Cc'ed for this).

> Jouni Malinen                                            PGP id EFC895FA

cu
Adrian



<--  snip  -->


I wanted to remove the #include "hostap_ioctl.c" from hostap.c and build 
hostap_ioctl.c separately, but this doesn't work since hostap.c has the 
same name as the module.

After renaming hostap.c this will be possible.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.14-mm2-full/drivers/net/wireless/hostap/Makefile.old	2005-11-13 17:10:33.000000000 +0100
+++ linux-2.6.14-mm2-full/drivers/net/wireless/hostap/Makefile	2005-11-13 17:11:11.000000000 +0100
@@ -1,3 +1,4 @@
+hostap-y := hostap_main.o
 obj-$(CONFIG_HOSTAP) += hostap.o
 
 obj-$(CONFIG_HOSTAP_CS) += hostap_cs.o
