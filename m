From: Thomas Graf <tgraf@suug.ch>
Subject: Re: softlockups when trying to restore an nft set of 1M entries
Date: Sat, 14 Feb 2015 04:32:10 +0000
Message-ID: <20150214043210.GA16393@casper.infradead.org>
References: <54DDE717.6090703@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Josh Hunt <johunt@akamai.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54DDE717.6090703@akamai.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/13/15 at 05:59am, Josh Hunt wrote:
> except inside the set definition above I add 1M random ipv4 addresses.
> Running "nft -f <filename>" will reproduce the problem. I also saw this when
> trying to do a restore of 250k entries.
> 
> There are a few problems going on from what I can tell. The first is
> the set defaults to 4 buckets and during restores the # of buckets does not
> increase. I'm currently investigating to understand why we don't expand the
> set on restores. However my guess into why we're softlockuping here is that
> we're trying to shove 1M entries into 4 buckets :)

Agreed. If you grow from 4 to cover 1M entries you need countless
growth cycles and you end up creating huge chains which will make the
ongoing expands take even longer.

I think we need to implement Herbert's suggestion and have inserts
fail if a certain upper watermark is reached.

I'm also investigating if we can grow by n*2 instead of just *2.
