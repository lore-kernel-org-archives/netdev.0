From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: alx: use custom skb allocator
Date: Thu, 26 May 2016 06:08:22 -0700
Message-ID: <1464268102.5939.88.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464158994-7725-1-git-send-email-feng.tang@intel.com>
	 <20160525.195341.342679643310465817.davem@davemloft.net>
	 <20160526084155.GB11823@shbuild888>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, edumazet@google.com,
	johannes@sipsolutions.net, jarod@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Feng Tang <feng.tang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160526084155.GB11823@shbuild888>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-05-26 at 16:41 +0800, Feng Tang wrote:
> On Wed, May 25, 2016 at 07:53:41PM -0400, David Miller wrote:

> > 
> > But now that we have at least two instances of this code we really
> > need to put a common version somewhere. :-/
> 
> I agree, and furthermore I noticed there are some similar routines
> in the 4 individual Atheros drivers atlx/alx/atl1c/atl1e, which may
> be unified by a simple framework for them all. Maybe the driver
> maintainer from Atheros could take a look, as they can reach all
> the real HWs :)

Note that you could also use the napi_get_frags() API that other drivers
use, and you attach page frags to the skb.

(Ie use small skb->head allocations where the stack will pull the
headers, but use your own page based allocations for the frames)

This might allow you to use the page reuse trick that some Intel drivers
use.

Look for igb_can_reuse_rx_page() for an example.

Thanks.
