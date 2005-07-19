From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Mon, 18 Jul 2005 20:31:45 -0700 (PDT)
Message-ID: <20050718.203145.105430424.davem@davemloft.net>
References: <20050717220451.GB13434@rama.risq.ericsson.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050717220451.GB13434@rama.risq.ericsson.ca>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Harald Welte <laforge@netfilter.org>
Date: Mon, 18 Jul 2005 00:04:51 +0200

> The only real in-tree user of nfcache was IPVS, who only needs a single
> bit.  Unfortunately I couldn't find some other free bit in sk_buff to
> stuff that bit into, so I introduced a separate field for them.  Maybe
> the IPVS guys can resolve that to further save space.

I think we must resolve this one before 2.6.14 goes out, which
gives us a lot of time, but for now I'll eat that one-bit member.

> Initially I wanted to shrink pkt_type to three bits (PACKET_HOST and
> alike are only 6 values defined), but unfortunately the bluetooth code
> overloads pkt_type :(

This also must be cured somehow, that really isn't a clean nor nice
usage of this field.

> - remove all never-implemented 'nfcache' code
> - don't have ipvs code abuse 'nfcache' field. currently get's their own
>   compile-conditional skb->ipvs_property field.  IPVS maintainers can
>   decide to move this bit elswhere, but nfcache needs to die.
> - remove skb->nfcache field to save 4 bytes
> - move skb->nfctinfo into three unused bits to save further 4 bytes
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied, thanks Harald.
