From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 1/6] netns brnetfilter: per-netns ebtables
Date: Mon, 13 Oct 2008 11:35:01 +0400
Message-ID: <20081013073501.GB4254@x200.localdomain>
References: <20080821221943.GO31136@x200.localdomain> <20081013070347.GA3813@elte.hu> <20081013070940.GA6340@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, kaber@trash.et,
	"David S. Miller" <davem@davemloft.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:49682 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754390AbYJMHcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 03:32:11 -0400
Received: by nf-out-0910.google.com with SMTP id d3so644657nfc.21
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2008 00:32:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081013070940.GA6340@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 09:09:40AM +0200, Ingo Molnar wrote:
> 
> * Ingo Molnar <mingo@elte.hu> wrote:
> 
> > 
> > * adobriyan@gmail.com <adobriyan@gmail.com> wrote:
> > 
> > > * make registered ebtables list per-netns
> > > * for that, duplicate table at the very beginning of register,
> > >   we can't add one table to multiple lists.
> > > * propagate netns from userspace socket down to iterators over list,
> > > * register individual modules only in init_net for a minute.
> > > 
> > > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> > 
> > -tip testing found this build failure, config attached:
> > 
> > ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_nat.ko] undefined!
> > ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_nat.ko] undefined!
> > ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_nat.ko] undefined!
> > ERROR: "ebt_unregister_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> > ERROR: "ebt_register_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> > ERROR: "ebt_do_table" [net/bridge/netfilter/ebtable_broute.ko] undefined!
> > make[1]: *** [__modpost] Error 1
> > make: *** [modules] Error 2
> 
> i had a quick look and i think the problem is that CONFIG_BRIDGE=m so 
> the ebt_unregister_table symbol is not available to modules properly. 
> But i've not dug down deep.

Ouch, how they managed to get there?

Anyway, ebtables were rewritten to work via xtables, so these patches
are most certainly obsolete, better drop and forget. I should post new
version soon.
