From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/6] netns brnetfilter: per-netns ebtables
Date: Mon, 13 Oct 2008 09:09:40 +0200
Message-ID: <20081013070940.GA6340@elte.hu>
References: <20080821221943.GO31136@x200.localdomain> <20081013070347.GA3813@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.et,
	"David S. Miller" <davem@davemloft.net>
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:41518 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754460AbYJMHJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 03:09:56 -0400
Content-Disposition: inline
In-Reply-To: <20081013070347.GA3813@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> 
> * adobriyan@gmail.com <adobriyan@gmail.com> wrote:
> 
> > * make registered ebtables list per-netns
> > * for that, duplicate table at the very beginning of register,
> >   we can't add one table to multiple lists.
> > * propagate netns from userspace socket down to iterators over list,
> > * register individual modules only in init_net for a minute.
> > 
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> -tip testing found this build failure, config attached:
> 
> ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_nat.ko] undefined!
> ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_nat.ko] undefined!
> ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_nat.ko] undefined!
> ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2

i had a quick look and i think the problem is that CONFIG_BRIDGE=m so 
the ebt_unregister_table symbol is not available to modules properly. 
But i've not dug down deep.

	Ingo
