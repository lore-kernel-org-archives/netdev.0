From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] net: use right lock in __dev_remove_offload
Date: Fri, 16 Nov 2012 13:15:54 -0500
Message-ID: <50A682DA.2060201@redhat.com>
References: <1353089303.10798.38.camel@edumazet-glaptop>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903Ab2KPSP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2012 13:15:57 -0500
In-Reply-To: <1353089303.10798.38.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2012 01:08 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> offload_base is protected by offload_lock, not ptype_lock
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   net/core/dev.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index cf105e8..2705a2a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -513,7 +513,7 @@ void __dev_remove_offload(struct packet_offload *po)
>   	struct list_head *head = &offload_base;
>   	struct packet_offload *po1;
>
> -	spin_lock(&ptype_lock);
> +	spin_lock(&offload_lock);
>
>   	list_for_each_entry(po1, head, list) {
>   		if (po == po1) {
> @@ -524,7 +524,7 @@ void __dev_remove_offload(struct packet_offload *po)
>
>   	pr_warn("dev_remove_offload: %p not found\n", po);
>   out:
> -	spin_unlock(&ptype_lock);
> +	spin_unlock(&offload_lock);
>   }
>   EXPORT_SYMBOL(__dev_remove_offload);
>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

I distinctly remember changing that, but just look at my patches and 
it's there.... Sorry...

-vlad
