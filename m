From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iptables: xt_hashlimit fix
Date: Fri, 20 Feb 2009 19:33:43 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902201919390.5911@fbirervta.pbzchgretzou.qr>
References: <20090218051906.174295181@vyatta.com> <20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <499EF222.3060507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499EF222.3060507@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2009-02-20 19:10, Eric Dumazet wrote:
>
>Damned this broke xt_hashlimit, version=0
>Look file "net/netfilter/xt_hashlimit.c" line 706
>
>    /* Ugly hack: For SMP, we only want to use one set */
>    r->u.master = r;
>
>So, it appears some modules are using pointers to themselves, what a hack :(
>We probably need an audit of other modules.

xt_limit and xt_statistic are affected; I'll happily fix that up.

>Commit 784544739a25c30637397ace5489eeb6e15d7d49
>(netfilter: iptables: lock free counters) broke xt_hashlimit netfilter module :
>
>This module was storing a pointer inside its xt_hashlimit_info, and 
>this pointer is not relocated when we temporarly switch tables 
>(iptables -L).

Patch ok.
