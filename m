From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] sctp: check dst 'NULL' before use it in, sctp_packet_transmit
Date: Wed, 25 Dec 2013 11:24:06 +0100
Message-ID: <52BAB246.7060709@redhat.com>
References: <52BA8DA2.6030405@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665Ab3LYKYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Dec 2013 05:24:46 -0500
In-Reply-To: <52BA8DA2.6030405@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/25/2013 08:47 AM, Wang Weidong wrote:
> skb_dst_set will use dst, if dst is NULL although is not a problem,
> then goto the no_route and free nskb, so do the skb_dst_set is pointless.
> so check dst before use it. Remove the unnecessary initialization as well.

Please also cc linux-sctp as you did before!

Just went through the code, only reading from your subject title it first
sounded like a NULL pointer dereference, but in fact the code is fine and
nothing is wrong with it. I'd suggest you should make the subject sound
more "harmless" to not confuse people, imho, since all you do here is some
cleanup and rearrangement. "Use" sounds to me as dereferencing dst that is
NULL.

> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>   net/sctp/output.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index 3be70a4..9b76d62 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -387,7 +387,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>   	int err = 0;
>   	int padding;		/* How much padding do we need?  */
>   	__u8 has_data = 0;
> -	struct dst_entry *dst = tp->dst;
> +	struct dst_entry *dst;
>   	unsigned char *auth = NULL;	/* pointer to auth in skb data */
>
>   	pr_debug("%s: packet:%p\n", __func__, packet);
> @@ -420,9 +420,9 @@ int sctp_packet_transmit(struct sctp_packet *packet)
>   		}
>   	}
>   	dst = dst_clone(tp->dst);
> -	skb_dst_set(nskb, dst);
>   	if (!dst)
>   		goto no_route;

Nit: you should set a newline here.

> +	skb_dst_set(nskb, dst);
>
>   	/* Build the SCTP header.  */
>   	sh = (struct sctphdr *)skb_push(nskb, sizeof(struct sctphdr));
>
