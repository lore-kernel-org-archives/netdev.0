From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iptables: xt_hashlimit fix
Date: Tue, 24 Feb 2009 15:31:35 +0100
Message-ID: <49A404C7.1010900@trash.net>
References: <20090218051906.174295181@vyatta.com>	<20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <499EF222.3060507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499EF222.3060507@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Damned this broke xt_hashlimit, version=0
> 
> ...
> So, it appears some modules are using pointers to themselves, what a hack :(

Indeed. This is unfortunately necessary in some cases to make sure
that modules using global state actually use global state instead
of the per-CPU copies.

> We probably need an audit of other modules.
> 
> (net/netfilter/xt_statistic.c, net/netfilter/xt_quota.c,
> net/netfilter/xt_limit.c ...)

This seems fine in case of hashlimit since it the match data
is read-only. In case of statistic and quota I think we still
need it I think.

> Unfortunatly I wont have time to do this in following days, any volunteer ?
> 
> Thank you
> 
> [PATCH] netfilter: xt_hashlimit fix
> 
> Commit 784544739a25c30637397ace5489eeb6e15d7d49
> (netfilter: iptables: lock free counters) broke xt_hashlimit netfilter module :
> 
> This module was storing a pointer inside its xt_hashlimit_info, and this pointer
> is not relocated when we temporarly switch tables (iptables -L).
> 
> This hack is not not needed at all (probably a leftover from
> ancient time), as each cpu should and can access to its own copy.

Applied, thanks.
