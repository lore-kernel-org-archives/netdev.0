From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: 2.6.28-git1 gianfar compile failure (ppc).
Date: Fri, 9 Jan 2009 12:10:38 -0600
Message-ID: <2acbd3e40901091010r38d221b5nc2b2c98b589e55cb@mail.gmail.com>
References: <20081229054026.GA14962@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Dai Haruki" <dai.haruki@freescale.com>,
	"Andy Fleming" <afleming@freescale.com>, netdev@vger.kernel.org
To: "Dave Jones" <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:62309 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbZAISKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 13:10:40 -0500
Received: by wf-out-1314.google.com with SMTP id 27so9965770wfd.4
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 10:10:39 -0800 (PST)
In-Reply-To: <20081229054026.GA14962@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 28, 2008 at 11:41 PM, Dave Jones <davej@redhat.com> wrote:
> ERROR: "cacheable_memzero" [drivers/net/gianfar_driver.ko] undefined!
>
> Introduced in a22823e72a4821ce1d4a248fbd8f5a81795af339
>
> I guess that needs exporting for when gianfar is modular, but I've no
> idea how to export things from powerpc assembly.
>
>        Dave
>


This patch which was posted to linuxppc-dev should fix your bug:

From: Kumar Gala <galak@kernel.crashing.org>
Date: Tue, Jan 6, 2009 at 11:00 PM
Subject: [PATCH] powerpc: Export cacheable_memzero as its now used in a driver
To: linuxppc-dev@ozlabs.org


The Freescale PowerPC specific gianfar driver (gig-e) uses
cacheable_memzero for performance reasons we need to export
the symbol to allow the driver to be built as a module.

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
 arch/powerpc/kernel/ppc_ksyms.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/kernel/ppc_ksyms.c b/arch/powerpc/kernel/ppc_ksyms.c
index dcec132..c8b27bb 100644
--- a/arch/powerpc/kernel/ppc_ksyms.c
+++ b/arch/powerpc/kernel/ppc_ksyms.c
@@ -165,6 +165,7 @@ EXPORT_SYMBOL(timer_interrupt);
 EXPORT_SYMBOL(irq_desc);
 EXPORT_SYMBOL(tb_ticks_per_jiffy);
 EXPORT_SYMBOL(cacheable_memcpy);
+EXPORT_SYMBOL(cacheable_memzero);
 #endif

 #ifdef CONFIG_PPC32
--
1.5.6.5
