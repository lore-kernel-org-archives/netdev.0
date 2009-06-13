From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] net/netfilter: Convert printk uses to pr_<level>
Date: Sat, 13 Jun 2009 12:45:15 +0200
Message-ID: <4A33833B.4080609@trash.net>
References: <cover.1244705154.git.joe@perches.com> <835d5482f92aa00f571b2775b96e0e555c31bcf8.1244705154.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34671 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714AbZFMKpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 06:45:16 -0400
In-Reply-To: <835d5482f92aa00f571b2775b96e0e555c31bcf8.1244705154.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> Remove function names from format strings
> Add #define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__

In my opinion a lot of the debugging messages should simply be
removed, they provide little informational value and decrease
readability of the code. Unfortunately I couldn't convince
everyone of that.

>  #ifdef CONFIG_NF_CT_ACCT
> -	printk(KERN_WARNING "CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use\n");
> -		printk(KERN_WARNING "nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or\n");
> -		printk(KERN_WARNING "sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");
> +		pr_warning("CONFIG_NF_CT_ACCT is deprecated and will be removed soon.\n");
> +		pr_warning("Please use nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack\n");
> +		pr_warning("module option or sysctl net.netfilter.nf_conntrack_acct=1 to enable it.\n");

For non-debugging messages that should provide enough information
to make sense of them without function names, this change does not
make much sense in my opinion.

Instead of a half-way readable message, we now would get:

nf_conntrack: nf_conntrack_acct_init: CONFIG_NF_CT_ACCT is deprecated ...

which is not an improvement at all. So unless we can limit this
to debugging message, I'll pass on this change.
