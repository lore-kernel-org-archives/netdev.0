From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH v1 5/5] wave: Added basic version of TCP Wave
Date: Sat, 29 Jul 2017 08:32:34 -0700
Message-ID: <20170729083234.57f58ab5@xeon-e3>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
        <20170728195919.10099-6-natale.patriciello@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: Natale Patriciello <natale.patriciello@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34470 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752505AbdG2Pch (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 11:32:37 -0400
Received: by mail-pg0-f45.google.com with SMTP id u185so16333365pgb.1
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 08:32:37 -0700 (PDT)
In-Reply-To: <20170728195919.10099-6-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Jul 2017 21:59:19 +0200
Natale Patriciello <natale.patriciello@gmail.com> wrote:

> +
> +#define WAVE_DEBUG 1
> +
> +#ifdef WAVE_DEBUG
> +	#define DBG(msg ...) printk(KERN_DEBUG "WAVE_DEBUG: " msg)
> +#else
> +	static inline void DBG(const char *msg, ...) { }
> +#endif
> +

Don't reinvent your own debug macros.
Use standard pr_debug instead.

+
+	if (ca->history != 0)
+		kfree(ca->history);

First, off the comparison should be with NULL not 0.
Secondly, kfree already does the right thing with kfree(NULL).

+		/* Usually the burst end is also reflected in the rs->delivered
+		 * variable. If this is not the case, and such variable is
+		 * behind just for 1 segment, then do this experimental thing
+		 * to re-allineate the burst with the rs->delivered variable.
+		 * In the majority of cases, we went out of allineation because
+		 * of a tail loss probe. */

Put the last */ in column with other parts of block.
		* of a tail loss probe.
		*/
