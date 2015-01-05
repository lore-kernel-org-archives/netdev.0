From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2] nftables: nft_flush_table: handle chain dependencies
Date: Mon, 5 Jan 2015 12:39:07 +0100
Message-ID: <20150105113907.GA15161@salvia>
References: <1419634318-18303-1-git-send-email-asbjorn@asbjorn.biz>
 <1419640765-7707-1-git-send-email-asbjorn@asbjorn.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1419640765-7707-1-git-send-email-asbjorn@asbjorn.biz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 27, 2014 at 12:39:25AM +0000, Asbjoern Sloth Toennesen wrote:
> Update: I errously assumed that git add, while writing the commit
> message, would be added to the commit.
> Based on net-next f96fe225. Compiles and checkpatch clean.
> 
> Jumping between chains doesn't mix well with flush ruleset,
> since nft_flush_table doesn't handle chains referencing chains.
> 
> This way it will take one to two loops, to settle.
> Alternatively it can be solved by always having two loops,

I just sent you a different patch to address this, we may still have
references from the elements to chains when using dictionaries, so I
prefer to schedule the object release in this order:

rules -> sets -> chains -> tables

Thanks for diagnosing and sending an initial fix.

P.S: I hope you enjoyed 31c3.
