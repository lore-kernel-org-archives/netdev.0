From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 net-next] net: core: decouple ifalias get/set from
 rtnl lock
Date: Mon, 2 Oct 2017 23:47:35 +0200
Message-ID: <20171002214735.GA1813@breakpoint.cc>
References: <20171002212942.14521-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43860 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750940AbdJBVrh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 17:47:37 -0400
Content-Disposition: inline
In-Reply-To: <20171002212942.14521-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> wrote:
> +	mutex_lock(&ifalias_mutex);
> +
> +	old = rcu_dereference_protected(dev->ifalias,
> +					mutex_is_locked(&ifalias_mutex));
> +	if (len) {
> +		memcpy(new_alias->ifalias, alias, len);
> +		new_alias->ifalias[len] = 0;
> +	}

This can be done outside of the lock, so this can be
> +
> +	rcu_assign_pointer(dev->ifalias, new_alias);

rcu_swap_protected().

I'll send a v3.
