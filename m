From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2] rhashtable: involve rhashtable_lookup_insert
 routine
Date: Mon, 5 Jan 2015 21:52:37 +0000
Message-ID: <20150105215237.GC31637@casper.infradead.org>
References: <1420457634-13017-1-git-send-email-ying.xue@windriver.com>
 <20150105130514.GA15499@casper.infradead.org>
 <20150105.163018.658637009804208069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ying.xue@windriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49464 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753240AbbAEVwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 16:52:39 -0500
Content-Disposition: inline
In-Reply-To: <20150105.163018.658637009804208069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/15 at 04:30pm, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Mon, 5 Jan 2015 13:05:14 +0000
> 
> > On 01/05/15 at 07:33pm, Ying Xue wrote:
> >> Involve a new function called rhashtable_lookup_insert() which makes
> >> lookup and insertion atomic under bucket lock protection, helping us
> >> avoid to introduce an extra lock when we search and insert an object
> >> into hash table.
> >> 
> >> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> >> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > 
> > Thanks for putting this around so quickly and thanks for testing.
> > I think this looks good. You might be able to factor out some code
> > from rhashtable_insert() to avoid duplication so we reduce the risk
> > of fixing a bug for one function but not the other.
> 
> Do you want Ying to do this factoring out now in a v3 of this patch
> or in a subsequent patch?
> 
> I assume the former since you didn't give your ACK.

Ying,

I prefer it now if you don't mind. Basically I would like to see the
grow decision factored out at least:

        /* Only grow the table if no resizing is currently in progress. */
        if (ht->tbl != ht->future_tbl &&
            ht->p.grow_decision && ht->p.grow_decision(ht, tbl->size))
                schedule_delayed_work(&ht->run_work, 0);
