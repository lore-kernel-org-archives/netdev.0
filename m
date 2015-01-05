From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2] rhashtable: involve rhashtable_lookup_insert
 routine
Date: Mon, 5 Jan 2015 13:05:14 +0000
Message-ID: <20150105130514.GA15499@casper.infradead.org>
References: <1420457634-13017-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46784 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbbAENFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 08:05:17 -0500
Content-Disposition: inline
In-Reply-To: <1420457634-13017-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/15 at 07:33pm, Ying Xue wrote:
> Involve a new function called rhashtable_lookup_insert() which makes
> lookup and insertion atomic under bucket lock protection, helping us
> avoid to introduce an extra lock when we search and insert an object
> into hash table.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thanks for putting this around so quickly and thanks for testing.
I think this looks good. You might be able to factor out some code
from rhashtable_insert() to avoid duplication so we reduce the risk
of fixing a bug for one function but not the other.

I see some further optimization potential when we need to calculate
the hash for both the old and new table. We can introduce a new
function which provides both based on a single hash iteration.
However, we should do that in a separate patch.
