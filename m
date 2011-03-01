From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
Date: Tue, 1 Mar 2011 09:11:31 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1103010909320.6253@router.home>
References: <4D6CA852.3060303@cn.fujitsu.com> <AANLkTimXy2Yaj+NTDMNTWuLqHHfKZJhVDpeXj3CfMvBf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pekka Enberg <penberg@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.prem.mail.ac4.yahoo.com ([76.13.13.92]:27698 "HELO
	smtp109.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756566Ab1CAPLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 10:11:35 -0500
In-Reply-To: <AANLkTimXy2Yaj+NTDMNTWuLqHHfKZJhVDpeXj3CfMvBf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Mar 2011, Pekka Enberg wrote:

> The SLAB and SLUB patches are fine by me if there are going to be real
> users for this. Christoph, Paul?

The solution is a bit overkill. It would be much simpler to add a union to
struct page that has lru and the rcu in there similar things can be done
for SLAB and the network layer. A similar issue already exists for the
spinlock in struct page. Lets follow the existing way of handling this.

Struct page may be larger for debugging purposes already because of the
need for extended spinlock data.
