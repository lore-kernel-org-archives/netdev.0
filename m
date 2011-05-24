From: Joe Perches <joe@perches.com>
Subject: Re: [patch 1/1] net: convert %p usage to %pK
Date: Mon, 23 May 2011 23:33:13 -0700
Message-ID: <1306218793.2298.10.camel@Joe-Laptop>
References: <201105232217.p4NMHZiC015498@imap1.linux-foundation.org>
	 <20110524.011330.1077020828173889583.davem@davemloft.net>
	 <1306217837.2638.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, drosenberg@vsecurity.com,
	a.p.zijlstra@chello.nl, eparis@parisplace.org,
	eugeneteo@kernel.org, jmorris@namei.org, kees.cook@canonical.com,
	mingo@elte.hu, tgraf@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1932 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490Ab1EXGdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 02:33:16 -0400
In-Reply-To: <1306217837.2638.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-24 at 08:17 +0200, Eric Dumazet wrote:
> We probably need to extend this to inet_diag as well.
> Provide a mayber_hide_ptr() helper and use it in inet_diag to not
> disclose kernel pointers to user, with kptr_restrict logic :
> kptr_restrict = 0 : kernel pointers are not mangled
> kptr_restrict = 1 : if the current user does not have CAP_SYSLOG,
> kernel pointers are replaced by 0
> kptr_restrict = 2 : kernel pointers are replaced by 0
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
[]
> +void *maybe_hide_ptr(void *ptr)
> +{
> +	if (!((kptr_restrict == 0) ||
> +	      (kptr_restrict == 1 &&
> +	       has_capability_noaudit(current, CAP_SYSLOG))))
> +		ptr = NULL;
> +	return ptr;
> +}
> +EXPORT_SYMBOL(maybe_hide_ptr);

Makes sense to me.

Maybe for clarity it'd be better to use a switch/case
or something like:

	if (kptr_restrict == 0)
		return ptr;
	if (ptr_restrict == 1 &&
	    has_capability_noaudit(current, CAP_SYSLOG))
		return ptr;
	return NULL;


