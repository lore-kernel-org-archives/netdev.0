From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [RFC 1/2] netfilter: xt_condition: export list management code
Date: Mon, 19 Jul 2010 18:13:50 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007191807020.19191@obet.zrqbmnf.qr>
References: <1279548947-10470-1-git-send-email-luciano.coelho@nokia.com> <1279548947-10470-2-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, sameo@linux.intel.com
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:54910 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936320Ab0GSQNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 12:13:51 -0400
In-Reply-To: <1279548947-10470-2-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 2010-07-19 16:15, Luciano Coelho wrote:

>From: Luciano Coelho <coelho@testbed>
>
>This patch isolates and exports the condition list management code, in
>preparation for the CONDITION target to use it.  No functional change,
>just reorganization of the code.

Well, I guess it would make more sense if the two extensions be in a 
single file. That would alleviate the need for export reorganizations, 
and also works because the module metadata overhead is large already.

>@@ -3,12 +3,27 @@
> 
> #include <linux/types.h>
> 
>+#define XT_CONDITION_MAX_NAME_SIZE 30
>+
> struct xt_condition_mtinfo {
>-	char name[31];
>+	char name[XT_CONDITION_MAX_NAME_SIZE + 1];
> 	__u8 invert;

Oh noes. Please please avoid any math operations inside []. It has 
already driven XT_FUNCTION_MAXNAMELEN into nuts ("was it now +1 or -1, 
or even -2 that we needed to pass for various functions?"). Just let MAX 
be 31 and have name[MAX].

> MODULE_ALIAS("ip6t_condition");
> 
>-struct condition_variable {
>-	struct list_head list;
>-	struct proc_dir_entry *status_proc;
>-	unsigned int refcount;
>-	bool enabled;
>-};

Given your excellent usage example of a CONDITION target, I think it 
even makes sense to enlarge the "enabled" variable to a full-fledged 
32-bit value that can be &, | and ^'d, similar to nfmark.
