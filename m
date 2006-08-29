From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Wed, 30 Aug 2006 03:21:26 +0400
Message-ID: <20060829232126.GA18636@ms2.inr.ac.ru>
References: <20060828230748.827712918@localhost.localdomain> <20060828230915.587544687@localhost.localdomain> <20060829152816.GA24283@ms2.inr.ac.ru> <20060829112204.0cf5e866@localhost.localdomain> <20060829211722.GA27855@ms2.inr.ac.ru> <20060829144608.012f0d60@dxpl.pdx.osdl.net> <20060829221606.GA10285@ms2.inr.ac.ru> <20060829160022.552d46e0@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:58821 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1750811AbWH2XVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 19:21:36 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060829160022.552d46e0@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> This should not be any more racy than the existing code.

Existing code is not racy.

Critical place is interpretation of refcnt==1. Current code assumes,
that when refcnt=1 and entry is in hash table, nobody can take this
entry (table is locked). So, it can be unlinked from the table.

See? __neigh_lookup()/__neigh_lookup_errno() _MUST_ return alive
and hashed entry. And will stay hashed until the reference is held.
Or until neigh entry is forced for destruction by device going down,
in this case referring dst entries will die as well.

If dst cache grabs an entry, which is purged from table because for some
time it had refcnt==1, you got a valid dst entry referring to dead
neighbour entry.

Alexey
