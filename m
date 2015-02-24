From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 08:59:09 +0000
Message-ID: <20150224085909.GC17306@casper.infradead.org>
References: <20150223184904.GA24955@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	kaber@trash.net, ying.xue@windriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, josh@joshtriplett.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44335 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbbBXI7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 03:59:11 -0500
Content-Disposition: inline
In-Reply-To: <20150223184904.GA24955@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/15 at 10:49am, Paul E. McKenney wrote:
> Hello!
> 
> Alexei mentioned that there was some excitement a couple of weeks ago in
> Ottawa, something about the resizing taking forever when there were large
> numbers of concurrent additions.  One approach comes to mind:

@Dave et al,
Just want to make sure we have the same level of understanding of
urgency for this. The only practical problem experienced so far is
loading n*1M entries into an nft_hash set which takes 3s for 4M
entries upon restore. A regular add is actually fine as it provides
a hint and sizes the table accordingly.

I agree that rhashtable should be improved to better handle many
inserts on small tables but wanted to make sure whether anyone thinks
this needs urgent fixing in 3.20 or whether we can take some time to
fully understand all scenarios and experiment with ideas and then
propose solutions for the next merge window. I also have the TCP hash
tables on my radar while improving this.
