From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [ofa-general] [PATCH] RDMA/CMA: Use neigh_event_send() to initiate
	neighbour discovery.
Date: Sun, 16 Sep 2007 10:34:23 +0300
Message-ID: <46ECDC7F.2070805@voltaire.com>
References: <20070912100025.3190.89259.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070912100025.3190.89259.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> RDMA/CMA: Use neigh_event_send() to initiate neighbour discovery.
> 
> Calling arp_send() to initiate neighbour discovery (ND) doesn't do the
> full ND protocol.  Namely, it doesn't handle retransmitting the arp
> request if it is dropped. The function neigh_event_send() does all this.
> Without doing full ND, rdma address resolution fails in the presence of
> dropped arp bcast packets.

Jay,

Is there a way to deploy something similar for the gratuitous arp being 
sent by the bonding driver at bond_arp_send()?

We have seen rare situations where the skb was dropped by the stack and 
hence bonding fail-over was detected by the remote peer only when its 
neighboring subsystem probe failures dictated that a new arp must be issued.

Or.
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
> 
>  drivers/infiniband/core/addr.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
> index c5c33d3..5381c80 100644
> --- a/drivers/infiniband/core/addr.c
> +++ b/drivers/infiniband/core/addr.c
> @@ -161,8 +161,7 @@ static void addr_send_arp(struct sockadd
>  	if (ip_route_output_key(&rt, &fl))
>  		return;
>  
> -	arp_send(ARPOP_REQUEST, ETH_P_ARP, rt->rt_gateway, rt->idev->dev,
> -		 rt->rt_src, NULL, rt->idev->dev->dev_addr, NULL);
> +	neigh_event_send(rt->u.dst.neighbour, NULL);
>  	ip_rt_put(rt);
>  }
