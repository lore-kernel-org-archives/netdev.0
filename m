From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 3/5] rhashtable: use future table size to make
 expansion decision
Date: Tue, 6 Jan 2015 09:35:57 +0000
Message-ID: <20150106093557.GC12468@casper.infradead.org>
References: <1420529003-22244-1-git-send-email-ying.xue@windriver.com>
 <1420529003-22244-4-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, tipc-discussion@lists.sourceforge.net
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52975 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbbAFJf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 04:35:59 -0500
Content-Disposition: inline
In-Reply-To: <1420529003-22244-4-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/15 at 03:23pm, Ying Xue wrote:
> Should use future table size instead of old table size to decide
> whether hash table is worth being expanded.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> ---
>  lib/rhashtable.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

Apologies as you were probably mislead by the bug as commented
on in the previous patch.

I don't think we need this. future_tbl only points to a different
table until the old table entries are linked from the new table.
The condition in the resize check where meant to exclude this
phase so we would newer get to the deferred worker while relinking
is happening.
