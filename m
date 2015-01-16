From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 15:34:16 +0000
Message-ID: <20150116153415.GF30132@acer.localdomain>
References: <cover.1418647641.git.tgraf@suug.ch>
 <75db38bc9313a55cf02a8c36a3376c32b691e5d9.1418647641.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, edumazet@google.com,
	john.r.fastabend@intel.com, josh@joshtriplett.org,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43162 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbbAPPeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 10:34:22 -0500
Content-Disposition: inline
In-Reply-To: <75db38bc9313a55cf02a8c36a3376c32b691e5d9.1418647641.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.12, Thomas Graf wrote:
> The patch also defers expansion and shrinking to a worker queue which
> allows insertion and removal from atomic context. Insertions and
> deletions may occur in parallel to it and are only held up briefly
> while the particular bucket is linked or unzipped.
>
> Mutations of the bucket table pointer is protected by a new mutex, read
> access is RCU protected.
> 
> In the event of an expansion or shrinking, the new bucket table allocated
> is exposed as a so called future table as soon as the resize process
> starts.  Lookups, deletions, and insertions will briefly use both tables.
> The future table becomes the main table after an RCU grace period and
> initial linking of the old to the new table was performed. Optimization
> of the chains to make use of the new number of buckets follows only the
> new table is in use.

AFAICT nft_hash_walk() will miss new entries during this period.
Am I missing anything here?
