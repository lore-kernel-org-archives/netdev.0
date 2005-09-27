From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Tue, 27 Sep 2005 18:23:18 +0200
Message-ID: <200509271823.19365.ak@suse.de>
References: <432EF0C5.5090908@cosmosbay.com> <200509221503.21650.ak@suse.de> <20050923170911.GN731@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964980AbVI0QX2@vger.kernel.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050923170911.GN731@sunbeam.de.gnumonks.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 23 September 2005 19:09, Harald Welte wrote:
> On Thu, Sep 22, 2005 at 03:03:21PM +0200, Andi Kleen wrote:
> > > 1) No more central rwlock protecting each table (filter, nat, mangle,
> > > raw), but one lock per CPU. It avoids cache line ping pongs for each
> > > packet.
> >
> > Another useful change would be to not take the lock when there are no
> > rules. Currently just loading iptables has a large overhead.
>
> This is partially due to the netfilter hooks that are registered (so we
> always take nf_hook_slow() in the NF_HOOK() macro).

Not sure it's that. nf_hook_slow uses RCU, so it should be quite
fast.

> The default policies inside an iptables chain are internally implemented
> as a rule.  Thus, policies as built-in rules have packet/byte counters.

That could be special cased and done lockless, with the counting
done per CPU.

-Andi
