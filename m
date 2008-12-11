From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] update rwlock initialization for nat_table
Date: Thu, 11 Dec 2008 14:18:29 -0800
Message-ID: <20081211141829.cda39684.akpm@linux-foundation.org>
References: <alpine.DEB.1.10.0812101314460.11805@gandalf.stny.rr.com>
	<49400B7F.7040607@cosmosbay.com>
	<alpine.DEB.1.10.0812101504280.11805@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dada1@cosmosbay.com, mingo@elte.hu, acme@ghostprotocols.net,
	davem@davemloft.net
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44567 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754339AbYLKWS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 17:18:56 -0500
In-Reply-To: <alpine.DEB.1.10.0812101504280.11805@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Dec 2008 15:06:00 -0500 (EST)
Steven Rostedt <rostedt@goodmis.org> wrote:

> 
> The following patch is in:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git
> 
>     branch: cleanups
> 
> 
> Steven Rostedt (1):
>       update rwlock initialization for nat_table
> 
> ----
>  net/ipv4/netfilter/nf_nat_rule.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> ---------------------------
> commit d4175059c8f95e4cd58e0efaa85610ca59469fbd
> Author: Steven Rostedt <srostedt@redhat.com>
> Date:   Wed Dec 10 15:00:09 2008 -0500
> 
>     update rwlock initialization for nat_table
>     
>     Impact: clean up

It's more than a "cleanup"?

>     The commit e099a173573ce1ba171092aee7bb3c72ea686e59
>     (netfilter: netns nat: per-netns NAT table) renamed the
>     nat_table from __nat_table to nat_table without updating the
>     __RW_LOCK_UNLOCKED(__nat_table.lock).
>     
>     Signed-off-by: Steven Rostedt <srostedt@redhat.com>
> 
> diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
> index bea54a6..8d489e7 100644
> --- a/net/ipv4/netfilter/nf_nat_rule.c
> +++ b/net/ipv4/netfilter/nf_nat_rule.c
> @@ -61,7 +61,7 @@ static struct
>  static struct xt_table nat_table = {
>  	.name		= "nat",
>  	.valid_hooks	= NAT_VALID_HOOKS,
> -	.lock		= __RW_LOCK_UNLOCKED(__nat_table.lock),
> +	.lock		= __RW_LOCK_UNLOCKED(nat_table.lock),
>  	.me		= THIS_MODULE,
>  	.af		= AF_INET,
>  };

At present any lockdep messages relating to this lock will print the
wrong name.  So it's a nanobug, I think?

