From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/3] SGI Altix cross partition functionality (2nd
 revision)
Date: Wed, 23 Mar 2005 12:02:48 -0800
Message-ID: <20050323120248.03755d6b.davem@davemloft.net>
References: <4241C391.mailxHNA15A8V0@aqua.americas.sgi.com>
	<20050323195139.GC21418@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tony.luck@intel.com, netdev@oss.sgi.com, linux-ia64@vger.kernel.org
To: Dean Nelson <dcn@sgi.com>
In-Reply-To: <20050323195139.GC21418@sgi.com>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Mar 2005 13:51:39 -0600
Dean Nelson <dcn@sgi.com> wrote:

> This patch contains the cross partition pseudo-ethernet driver (XPNET)
> functional support module.
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>

Only a NIT or two.  You should be setting the last_rx
value.  Also, NETIF_F_HIGHDMA is pointless unless you
support NETIF_F_SG and thus paged SKBs.  skb->data will
never be placed in high memory, only non-linear SKB
scatterlist pages will.

I should probably add a debugging check at device
registration time, like we already do to make sure
NETIF_F_SG is not set unless some checksumming
capability is there as well.
