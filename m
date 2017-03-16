From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/5] net: Call sk_mark_napi_id() in the ACK
 receive path
Date: Thu, 16 Mar 2017 15:04:53 -0700
Message-ID: <1489701893.28631.248.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
         <20170316183244.15806.77453.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        sridhar.samudrala@intel.com, edumazet@google.com,
        davem@davemloft.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316183244.15806.77453.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-03-16 at 11:32 -0700, Alexander Duyck wrote:
> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
> 
> Call sk_mark_napi_id() in the ACK receive path of a TCP_NEW_SYN_RECV
> socket, so that sk->napi_id is set even if the socket hasn't yet received
> any data.  With this change we should be able to start busy polling
> slightly earlier.
> 
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  net/ipv4/tcp_ipv4.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 08d870e45658..b86002a296f1 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1687,6 +1687,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
>  			tcp_v4_send_reset(nsk, skb);
>  			goto discard_and_relse;
>  		} else {
> +			sk_mark_napi_id(nsk, skb);
>  			sock_put(sk);
>  			return 0;
>  		}
> 

Seems good, but what about IPv6 ?

Frankly this calls for the sk_mark_napi_id() being done in
tcp_child_process() instead of its four callers.
