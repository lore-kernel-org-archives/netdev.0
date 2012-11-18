From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: use bitmap_weight
Date: Sat, 17 Nov 2012 20:45:19 -0500
Message-ID: <50A83DAF.8000408@gmail.com>
References: <1353134389-25583-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	netdev@vger.kernel.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:64282 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501Ab2KRBpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2012 20:45:22 -0500
In-Reply-To: <1353134389-25583-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2012 01:39 AM, Akinobu Mita wrote:
> Use bitmap_weight to count the total number of bits set in bitmap.
>
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Cc: linux-sctp@vger.kernel.org
> Cc: netdev@vger.kernel.org

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/tsnmap.c | 8 ++------
>   1 file changed, 2 insertions(+), 6 deletions(-)
>
> diff --git a/net/sctp/tsnmap.c b/net/sctp/tsnmap.c
> index b5fb7c4..5f25e0c 100644
> --- a/net/sctp/tsnmap.c
> +++ b/net/sctp/tsnmap.c
> @@ -272,7 +272,7 @@ __u16 sctp_tsnmap_pending(struct sctp_tsnmap *map)
>   	__u32 max_tsn = map->max_tsn_seen;
>   	__u32 base_tsn = map->base_tsn;
>   	__u16 pending_data;
> -	u32 gap, i;
> +	u32 gap;
>
>   	pending_data = max_tsn - cum_tsn;
>   	gap = max_tsn - base_tsn;
> @@ -280,11 +280,7 @@ __u16 sctp_tsnmap_pending(struct sctp_tsnmap *map)
>   	if (gap == 0 || gap >= map->len)
>   		goto out;
>
> -	for (i = 0; i < gap+1; i++) {
> -		if (test_bit(i, map->tsn_map))
> -			pending_data--;
> -	}
> -
> +	pending_data -= bitmap_weight(map->tsn_map, gap + 1);
>   out:
>   	return pending_data;
>   }
>
