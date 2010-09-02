From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH] Add pr_dbg and pr_dbg_always (was: Re: [PATCH v2] net:
 arp: code cleanup)
Date: Thu, 02 Sep 2010 10:38:28 -0700
Message-ID: <1283449109.1797.347.camel@Joe-Laptop>
References: <1283415511-4772-1-git-send-email-xiaosuo@gmail.com>
	 <1283416053.2454.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1235 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761Ab0IBRic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Sep 2010 13:38:32 -0400
In-Reply-To: <1283416053.2454.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-09-02 at 10:27 +0200, Eric Dumazet wrote:
> Le jeudi 02 septembre 2010 =C3=A0 16:18 +0800, Changli Gao a =C3=A9cr=
it :
> > Replace printk(KERN_DEBUG...) with pr_debug(...).
> pr_debug() is not an exact replacement of printk(KERN_DEBUG ...)
> With pr_debug(), you need to recompile this file with -DDEBUG or
> CONFIG_DYNAMIC_DEBUG if you want to catch the messages.

That's also the reason I think there should a new
not conditionally compiled away KERN_DEBUG level like

#define pr_somename(fmt, arg) printk(KERN_DEBUG pr_fmt(fmt), ##arg)

where pr_somename is something moderately short like:

pr_debug_always
pr_debug_force
pr_debug_info
pr_dbg_always

pr_dbg wouldn't be good because it uses a similar name to
dev_dbg but not be conditionally compiled away.

I lean to pr_dbg_always.
I think  pr_dbg should be added for symmetry.

Anyone have other suggestions?

Just leave it alone is one, but I think that because there's
a message logging level below KERN_INFO that people find useful,
there should be an unconditional pr_<level> call for it.

So add pr_dbg, pr_dbg_always and pr_dbg_ratelimited to kernel.h.
---
 include/linux/kernel.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 2b0a35e..398f8db 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -416,6 +416,8 @@ extern int hex_to_bin(char ch);
         printk(KERN_NOTICE pr_fmt(fmt), ##__VA_ARGS__)
 #define pr_info(fmt, ...) \
         printk(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
+#define pr_dbg_always(fmt, ...) \
+        printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
 #define pr_cont(fmt, ...) \
 	printk(KERN_CONT fmt, ##__VA_ARGS__)
=20
@@ -441,6 +443,8 @@ extern int hex_to_bin(char ch);
 	({ if (0) printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__); 0; })
 #endif
=20
+#define pr_dbg pr_debug
+
 /*
  * ratelimited messages with local ratelimit_state,
  * no local ratelimit_state used in the !PRINTK case
@@ -474,6 +478,8 @@ extern int hex_to_bin(char ch);
 	printk_ratelimited(KERN_NOTICE pr_fmt(fmt), ##__VA_ARGS__)
 #define pr_info_ratelimited(fmt, ...) \
 	printk_ratelimited(KERN_INFO pr_fmt(fmt), ##__VA_ARGS__)
+#define pr_dbg_ratelimited(fmt, ...) \
+	printk_ratelimited(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
 /* no pr_cont_ratelimited, don't do that... */
 /* If you are writing a driver, please use dev_dbg instead */
 #if defined(DEBUG)


