From: Ingo Molnar <mingo@elte.hu>
Subject: [patch, -rc5-mm1] lock validator: remove softirq.c WARN_ON
Date: Tue, 30 May 2006 13:55:45 +0200
Message-ID: <20060530115545.GA7025@elte.hu>
References: <20060530022925.8a67b613.akpm@osdl.org> <447C261E.1090202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	alan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:10459 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1750925AbWE3Lz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 07:55:56 -0400
To: Jiri Slaby <jirislaby@gmail.com>
Content-Disposition: inline
In-Reply-To: <447C261E.1090202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jiri Slaby <jirislaby@gmail.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Andrew Morton napsal(a):
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17-rc5/2.6.17-rc5-mm1/
> 
> BUG: warning at /l/latest/xxx/kernel/softirq.c:86/local_bh_disable()

ok, that WARN_ON is over-eager. Fix is below:

--------------
Subject: lock validator: remove softirq.c WARN_ON
From: Ingo Molnar <mingo@elte.hu>

there is nothing wrong with calling local_bh_disable() in irqs-off
section (as long as the local_bh_enable isnt done with irqs-off),
so remove this over-eager WARN_ON().

Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 kernel/softirq.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux/kernel/softirq.c
===================================================================
--- linux.orig/kernel/softirq.c
+++ linux/kernel/softirq.c
@@ -83,7 +83,6 @@ static void __local_bh_disable(unsigned 
 
 void local_bh_disable(void)
 {
-	WARN_ON_ONCE(irqs_disabled());
 	__local_bh_disable((unsigned long)__builtin_return_address(0));
 }
 
